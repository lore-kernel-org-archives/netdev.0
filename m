From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: introduce dev_consume_skb_any()
Date: Thu, 5 Dec 2013 17:54:14 +0100
Message-ID: <20131205165414.GB21745@order.stressinduktion.org>
References: <20131203.165034.1085515763685633822.davem@davemloft.net> <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com> <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com> <1386247508.30495.180.camel@edumazet-glaptop2.roam.corp.google.com> <20131205141346.GB14095@order.stressinduktion.org> <1386254734.30495.186.camel@edumazet-glaptop2.roam.corp.google.com> <1386255952.30495.192.camel@edumazet-glaptop2.roam.corp.google.com> <20131205154438.GA21745@order.stressinduktion.org> <1386261485.30495.203.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33469 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756866Ab3LEQyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 11:54:15 -0500
Content-Disposition: inline
In-Reply-To: <1386261485.30495.203.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 08:38:05AM -0800, Eric Dumazet wrote:
> On Thu, 2013-12-05 at 16:44 +0100, Hannes Frederic Sowa wrote:
> 
> > It makes some sense but I did not grasp the whole ->users dependency
> > picture, yet. I guess the barrier is only needed when refcount drops
> > down to 0 and we don't necessarily need one when incrementing ->users.
> 
> If you are the only user of this skb, really no smp barrier is needed at
> all.
> 
> The problem comes when another cpu is working on the skb, and finally
> releases its reference on it.
> 
> Before releasing its reference, it must commit all changes it might have
> done onto skb. Otherwise another cpu might read stale data.
> 
> The smp_wmb() is done by the atomic_dec_and_test(), as it contains a
> full barrier.
> 
> So the smp_rmb() pairs with the barrier done in atomic_dec_and_test()

Ha, it all makes sense now! Thanks, Eric!

(Sorry for the noise but I find this kind of problems very interesting)
