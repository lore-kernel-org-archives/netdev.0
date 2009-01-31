From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Fri, 30 Jan 2009 19:54:12 -0800
Message-ID: <ada3af0qgez.fsf@cisco.com>
References: <20090130065721.GA4886@gondor.apana.org.au>
	<adaiqnwr91j.fsf@cisco.com>
	<20090130.135107.116108989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, aluno3@poczta.onet.pl, herbert@gondor.apana.org.au,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090130.135107.116108989.davem@davemloft.net> (David Miller's
	message of "Fri, 30 Jan 2009 13:51:07 -0800 (PST)")
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

 > > I don't believe this is accurate.  Calling skb_linearize() (on a kernel
 > > with CONFIG_HIGHMEM set) can end up calling local_bh_enable() in
 > > kunmap_skb_frag(), which can obviously cause problems if the initial
 > > context relies on having BHs disabled (as hard_start_xmit does).

 > local_bh_{enable,disable}() nests, so this is not a problem

Duh.  OK, then the only bugs seem to be that iw_nes does skb_linearize
with irqs off (due to being an LLTX driver), and mv643xx_eth leaks an
skb on its error path if skb_linearize fails.

 - R.
