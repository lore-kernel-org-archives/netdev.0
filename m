From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Wed, 28 Jan 2009 10:05:29 -0800
Message-ID: <adaljsvwbkm.fsf@cisco.com>
References: <497EF9AC.70104@poczta.onet.pl> <adawscgwbkj.fsf@cisco.com>
	<20090127.160750.120120703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090127.160750.120120703.davem@davemloft.net> (David Miller's
	message of "Tue, 27 Jan 2009 16:07:50 -0800 (PST)")
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

 > > but actually I still don't see how it's safe for a net driver to
 > > call skb_linearize() from its transmit routine, since there's a
 > > chance that that will unconditionally enable BHs?
 > 
 > It's simply not allowed.
 > 
 > dev_queue_xmit() at a higher level can do __skb_linearize()
 > because it does so before doing the rcu_read_lock_bh().

OK, thanks... what confused me is that several other drivers also do
skb_linearize() in their hard_start_xmit method... eg bnx2x,
via-velocity, mv643xx_eth.  So there are several other lurking bugs to
deal with here I guess.

 - R.
