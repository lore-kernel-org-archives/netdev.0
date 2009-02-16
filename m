From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] net/mv643xx: use GFP_ATOMIC while atomic
Date: Mon, 16 Feb 2009 15:54:30 +0100
Message-ID: <20090216145430.GW17914@xi.wantstofly.org>
References: <20090215092618.GA12280@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:56635 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbZBPOyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 09:54:32 -0500
Content-Disposition: inline
In-Reply-To: <20090215092618.GA12280@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 15, 2009 at 01:26:18AM -0800, Sebastian Andrzej Siewior wrote:

> dev_set_rx_mode() grabs netif_addr_lock_bh():
> 
> |BUG: sleeping function called from invalid context at /home/bigeasy/git/cryptodev-2.6/mm/slub.c:1599
> |in_atomic(): 1, irqs_disabled(): 0, pid: 859, name: ifconfig
> |2 locks held by ifconfig/859:
> | #0:  (rtnl_mutex){--..}, at: [<c0239ccc>] rtnl_lock+0x18/0x20
> | #1:  (_xmit_ETHER){-...}, at: [<c022d094>] dev_set_rx_mode+0x1c/0x30
> |[<c029f118>] (dump_stack+0x0/0x14) from [<c003df28>] (__might_sleep+0x11c/0x13c)
> |[<c003de0c>] (__might_sleep+0x0/0x13c) from [<c00a8854>] (kmem_cache_alloc+0x30/0xd4)
> | r5:c78093a0 r4:c034a47c
> |[<c00a8824>] (kmem_cache_alloc+0x0/0xd4) from [<c01a5fd0>] (mv643xx_eth_set_rx_mode+0x70/0x188)
> |[<c01a5f60>] (mv643xx_eth_set_rx_mode+0x0/0x188) from [<c022ced0>] (__dev_set_rx_mode+0x40/0xac)
> |[<c022ce90>] (__dev_set_rx_mode+0x0/0xac) from [<c022d09c>] (dev_set_rx_mode+0x24/0x30)
> | r6:00001043 r5:c78090f8 r4:c7809000
> |[<c022d078>] (dev_set_rx_mode+0x0/0x30) from [<c02304c4>] (dev_open+0xe4/0x114)
> | r5:c7809350 r4:c7809000
> |[<c02303e0>] (dev_open+0x0/0x114) from [<c022fd18>] (dev_change_flags+0xb0/0x190)
> | r5:00000041 r4:c7809000
> |[<c022fc68>] (dev_change_flags+0x0/0x190) from [<c0270250>] (devinet_ioctl+0x2f0/0x710)
> | r7:c7221e70 r6:c7aadb00 r5:00000000 r4:00000001
> |[<c026ff60>] (devinet_ioctl+0x0/0x710) from [<c02717c8>] (inet_ioctl+0xd4/0x110)
> |[<c02716f4>] (inet_ioctl+0x0/0x110) from [<c021fb74>] (sock_ioctl+0x1f4/0x254)
> | r4:c7242b40
> |[<c021f980>] (sock_ioctl+0x0/0x254) from [<c00b8160>] (vfs_ioctl+0x38/0x98)
> | r6:beec9bb8 r5:00008914 r4:c7242b40
> |[<c00b8128>] (vfs_ioctl+0x0/0x98) from [<c00b873c>] (do_vfs_ioctl+0x484/0x4d4)
> | r6:00008914 r5:c7242b40 r4:c74db1c0
> |[<c00b82b8>] (do_vfs_ioctl+0x0/0x4d4) from [<c00b87cc>] (sys_ioctl+0x40/0x64)
> |[<c00b878c>] (sys_ioctl+0x0/0x64) from [<c00269a0>] (ret_fast_syscall+0x0/0x2c)
> |[42949399.520000]  r7:00000036 r6:beec9c80 r5:00000041 r4:beec9bb8
> 
> Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>

Acked-by: Lennert Buytenhek <buytenh@marvell.com>

Thanks.


> ---
>  drivers/net/mv643xx_eth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index 7253a49..6977abe 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -1573,7 +1573,7 @@ oom:
>                 return;
>         }
> 
> -       mc_spec = kmalloc(0x200, GFP_KERNEL);
> +       mc_spec = kmalloc(0x200, GFP_ATOMIC);
>         if (mc_spec == NULL)
>                 goto oom;
>         mc_other = mc_spec + (0x100 >> 2);
> --
> 1.6.0.6
