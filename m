From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] wpan: use GFP_ATOMIC instead of GFP_KERNEL
Date: Tue, 05 Feb 2013 08:09:57 -0800
Message-ID: <1360080597.28557.5.camel@edumazet-glaptop>
References: <1360078474-24362-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:53675 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756147Ab3BEQKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 11:10:02 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so213138pab.19
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 08:10:01 -0800 (PST)
In-Reply-To: <1360078474-24362-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-05 at 16:34 +0100, Alexander Aring wrote:
> I got this message at runtime:
> 
> [   48.847347] BUG: scheduling while atomic: swapper/0/0/0x40000100
> [   48.853870] Modules linked in: autofs4
> [   48.857891] [<c0013db8>] (unwind_backtrace+0x0/0x11c) from [<c04cfb84>] (__schedule_bug+0x48/0x5c)
> [   48.867342] [<c04cfb84>] (__schedule_bug+0x48/0x5c) from [<c04e0f4c>] (__schedule+0x68/0x5bc)
> [   48.876357] [<c04e0f4c>] (__schedule+0x68/0x5bc) from [<c0063f0c>] (__cond_resched+0x24/0x34)
> [   48.885368] [<c0063f0c>] (__cond_resched+0x24/0x34) from [<c04e152c>] (_cond_resched+0x34/0x44)
> [   48.894559] [<c04e152c>] (_cond_resched+0x34/0x44) from [<c00e9b28>] (kmem_cache_alloc_trace+0x2c/0x158)
> [   48.904578] [<c00e9b28>] (kmem_cache_alloc_trace+0x2c/0x158) from [<c04baa3c>] (mac802154_header_create+0x44/0x2)
> [   48.915594] [<c04baa3c>] (mac802154_header_create+0x44/0x24c) from [<c04b8e50>] (lowpan_header_create.part.3+0x7)
> [   48.927157] [<c04b8e50>] (lowpan_header_create.part.3+0x734/0x79c) from [<c03ebc04>] (neigh_connected_output+0x9)
> [   48.938542] [<c03ebc04>] (neigh_connected_output+0x98/0xd0) from [<c0467d5c>] (ip6_finish_output2+0x374/0x45c)
> [   48.949102] [<c0467d5c>] (ip6_finish_output2+0x374/0x45c) from [<c0479bcc>] (ndisc_send_skb+0x174/0x22c)
> [   48.959101] [<c0479bcc>] (ndisc_send_skb+0x174/0x22c) from [<c047b138>] (ndisc_send_rs+0x3c/0x44)
> [   48.968473] [<c047b138>] (ndisc_send_rs+0x3c/0x44) from [<c046e3f0>] (addrconf_rs_timer+0xbc/0x16c)
> [   48.978032] [<c046e3f0>] (addrconf_rs_timer+0xbc/0x16c) from [<c00451fc>] (call_timer_fn+0x74/0x134)
> [   48.987675] [<c00451fc>] (call_timer_fn+0x74/0x134) from [<c0046984>] (run_timer_softirq+0x258/0x2d4)
> [   48.997417] [<c0046984>] (run_timer_softirq+0x258/0x2d4) from [<c003fb84>] (__do_softirq+0x118/0x248)
> [   49.007156] [<c003fb84>] (__do_softirq+0x118/0x248) from [<c003ff64>] (irq_exit+0x44/0x84)
> [   49.015890] [<c003ff64>] (irq_exit+0x44/0x84) from [<c000e780>] (handle_IRQ+0x7c/0xb8)
> [   49.024249] [<c000e780>] (handle_IRQ+0x7c/0xb8) from [<c000857c>] (omap3_intc_handle_irq+0x54/0x68)
> [   49.033801] [<c000857c>] (omap3_intc_handle_irq+0x54/0x68) from [<c04e2900>] (__irq_svc+0x40/0x50)
> [   49.043239] Exception stack(0xc074bf68 to 0xc074bfb0)
> [   49.048576] bf60:                   ffffffed 00000000 002f8000 00000000 c074a000 c07b6608
> [   49.057199] bf80: c04ec10c c0757618 80004059 413fc082 00000000 00000000 00000000 c074bfb0
> [   49.065821] bfa0: c000e904 c000e908 60000013 ffffffff
> [   49.071162] [<c04e2900>] (__irq_svc+0x40/0x50) from [<c000e908>] (default_idle+0x24/0x2c)
> [   49.079789] [<c000e908>] (default_idle+0x24/0x2c) from [<c000ea7c>] (cpu_idle+0x9c/0xf0)
> [   49.088328] [<c000ea7c>] (cpu_idle+0x9c/0xf0) from [<c06ff7dc>] (start_kernel+0x258/0x2a4)
> 
> It seems that mac802154_header_create is calling from a irq context.
> So kzalloc need GFP_ATOMIC flag.
> 
> This patch will fix it.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>  net/mac802154/wpan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
> index 98c867b..0d9e110 100644
> --- a/net/mac802154/wpan.c
> +++ b/net/mac802154/wpan.c
> @@ -143,7 +143,7 @@ static int mac802154_header_create(struct sk_buff *skb,
>  	if (!daddr)
>  		return -EINVAL;
>  
> -	head = kzalloc(MAC802154_FRAME_HARD_HEADER_LEN, GFP_KERNEL);
> +	head = kzalloc(MAC802154_FRAME_HARD_HEADER_LEN, GFP_ATOMIC);
>  	if (head == NULL)
>  		return -ENOMEM;
>  

Please remove this allocation, its absolutely not needed.

40 bytes on the stack are fine.

Thanks
