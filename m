From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH v2] ucc_geth: Reduce IRQ off in xmit path
Date: Fri, 21 Sep 2012 11:00:57 +0200
Message-ID: <OF9E2E40A6.F118E211-ONC1257A80.00315A3F-C1257A80.003186AA@transmode.se>
References: <20120919223416.GA16087@electric-eye.fr.zoreil.com>	<1348129021-28333-1-git-send-email-Joakim.Tjernlund@transmode.se> <20120920.170852.391382615902951147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:50049 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932072Ab2IUJBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 05:01:00 -0400
In-Reply-To: <20120920.170852.391382615902951147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 2012/09/20 23:08:52:
>
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Thu, 20 Sep 2012 10:17:01 +0200
>
> > Currently ucc_geth_start_xmit wraps IRQ off for the
> > whole body just to be safe.
> > Reduce the IRQ off period to a minimum.
> >
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> >
> >  v2: Move assignment of ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]]
> >      inside IRQ off section to prevent racing against
> >      ucc_geth_tx(). Spotted by Francois Romieu <romieu@fr.zoreil.com>
>
> I agree with Francois's initial analysis, and disagree with you're
> response to him, wrt. the suggest to remove all locking entirely.
>
> Unlike what you claim, there isn't much of a gain at all from merely
> make the window of lock holding smaller, especially on the scale
> in which you are doing it here.
>
> Whereas removing the lock and the atomic completely, as tg3 does,
> will give very significant performance gains.
>
> The locking cost of grabbing the spinlock, and the memory transactions
> associated with it, dominate.
>
> Furthermore, even if the gains of your change are non-trivial, you
> haven't documented it.  So unless you should some noticable gains from
> this, it's just code masterbation as far as I'm concerned and I'm
> therefore inclined to not apply patches like this.
>
> TG3's core interrupt locking is not that difficult to understand and
> replicate in other drivers, so I dismiss your attempts to avoid that
> approach on difficulty grounds as well.

OK, I will give it a go. Got something working that I will send in shortly.
I hope the other patches were OK?

 Jocke
