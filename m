From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Fri, 30 Jan 2009 09:35:52 -0800
Message-ID: <adaiqnwr91j.fsf@cisco.com>
References: <20090130065721.GA4886@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, aluno3@poczta.onet.pl, davem@davemloft.net,
	general@lists.openfabrics.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090130065721.GA4886@gondor.apana.org.au> (Herbert Xu's message
	of "Fri, 30 Jan 2009 17:57:21 +1100")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 > > OK, thanks... what confused me is that several other drivers also do
 > > skb_linearize() in their hard_start_xmit method... eg bnx2x,
 > > via-velocity, mv643xx_eth.  So there are several other lurking bugs to
 > > deal with here I guess.
 > 
 > I don't know about the rest but bnx2x is certainly OK since it
 > only does so with IRQ enabled.  It is legal to call skb_linearize
 > as long as you're sure that IRQs are enabled, which is always the
 > case for hard_start_xmit upon entry.

I don't believe this is accurate.  Calling skb_linearize() (on a kernel
with CONFIG_HIGHMEM set) can end up calling local_bh_enable() in
kunmap_skb_frag(), which can obviously cause problems if the initial
context relies on having BHs disabled (as hard_start_xmit does).

 - R.
