From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [BUG] latest net-next-2.6 doesnt fly
Date: Sun, 4 Apr 2010 19:19:07 +0900
Message-ID: <20100404191804R.fujita.tomonori@lab.ntt.co.jp>
References: <1270202304.1989.14.camel@edumazet-laptop>
	<20100404181542N.fujita.tomonori@lab.ntt.co.jp>
	<1270373395.1971.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	davem@davemloft.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:51172 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734Ab0DDKTO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Apr 2010 06:19:14 -0400
In-Reply-To: <1270373395.1971.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 04 Apr 2010 11:29:55 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > I think, if pdev is null, returning 1 here is safer since the device
> > doesn't set up dma info properly.
> > 
> > Do you know what device hits this bug? You said that you use bnx2 and
> > tg3. Both call SET_NETDEV_DEV with pdev->dev. I tested bnx2 and seems
> > that netdev->dev.parent is set up correctly.
> > --
> 
> Might be because of my setup, I suspect I had two reasons to hit the
> bug :
> 
> A bonding of eth2 (bnx2) and eth3 (tg3)
> 
> Then vlans on top of this bond0
> 
> When first dev_queue_xmit() was called, it was for a virtual device :)

Thanks! So it's due to bond or vlan (or both).

I guess that returning zero here with a null pdev is fine. If we
return 1, probably some people would complain about performance
regression. Like the block layer does, coping the dma restriction info
from the lower devices can solve this problem but I guess that it's
over engineering. My original patch doesn't loosen the DMA restriction
checking so returning zero shouldn't break anything. If when we fix
the usage of NETIF_F_HIGHDMA in each driver and also check the usage
of netdev->dev.parent, everything should be fine.
