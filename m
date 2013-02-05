From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] 6lowpan: use GFP_ATOMIC instead of GFP_KERNEL
Date: Tue, 5 Feb 2013 19:41:16 +0100
Message-ID: <20130205184114.GD1124@x61s.8.8.8.8>
References: <1360079862-15831-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	davem@davemloft.net, netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:44833 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754793Ab3BESkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 13:40:31 -0500
Received: by mail-bk0-f54.google.com with SMTP id w5so250656bku.27
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 10:40:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360079862-15831-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Feb 05, 2013 at 04:57:42PM +0100, Alexander Aring wrote:
> I got this message at runtime:
> 
> [  326.069622] BUG: scheduling while atomic: swapper/0/0/0x40000100
> [  326.076037] Modules linked in: autofs4
> [  326.080079] [<c0013db8>] (unwind_backtrace+0x0/0x11c) from [<c04cfb84>] (__schedule_bug+0x48/0x5c)
> [  326.089550] [<c04cfb84>] (__schedule_bug+0x48/0x5c) from [<c04e0f4c>] (__schedule+0x68/0x5bc)
> [  326.098575] [<c04e0f4c>] (__schedule+0x68/0x5bc) from [<c0063f0c>] (__cond_resched+0x24/0x34)
> [  326.107581] [<c0063f0c>] (__cond_resched+0x24/0x34) from [<c04e152c>] (_cond_resched+0x34/0x44)
> [  326.116781] [<c04e152c>] (_cond_resched+0x34/0x44) from [<c00e9b28>] (kmem_cache_alloc_trace+0x2c/0x158)
> [  326.126798] [<c00e9b28>] (kmem_cache_alloc_trace+0x2c/0x158) from [<c04b874c>] (lowpan_header_create.part.3+0x30)
> [  326.138186] [<c04b874c>] (lowpan_header_create.part.3+0x30/0x79c) from [<c03ebc04>] (neigh_connected_output+0x98)
> [  326.149488] [<c03ebc04>] (neigh_connected_output+0x98/0xd0) from [<c0467d5c>] (ip6_finish_output2+0x374/0x45c)
> [  326.160052] [<c0467d5c>] (ip6_finish_output2+0x374/0x45c) from [<c0479bcc>] (ndisc_send_skb+0x174/0x22c)
> [  326.170061] [<c0479bcc>] (ndisc_send_skb+0x174/0x22c) from [<c047afe4>] (ndisc_send_ns+0x8c/0x94)
> [  326.179418] [<c047afe4>] (ndisc_send_ns+0x8c/0x94) from [<c047b0e8>] (ndisc_solicit+0xfc/0x110)
> [  326.188593] [<c047b0e8>] (ndisc_solicit+0xfc/0x110) from [<c03ec348>] (neigh_probe+0x60/0x84)
> [  326.197590] [<c03ec348>] (neigh_probe+0x60/0x84) from [<c03ed118>] (neigh_timer_handler+0x1d4/0x238)
> [  326.207225] [<c03ed118>] (neigh_timer_handler+0x1d4/0x238) from [<c00451fc>] (call_timer_fn+0x74/0x134)
> [  326.217138] [<c00451fc>] (call_timer_fn+0x74/0x134) from [<c0046984>] (run_timer_softirq+0x258/0x2d4)
> [  326.226881] [<c0046984>] (run_timer_softirq+0x258/0x2d4) from [<c003fb84>] (__do_softirq+0x118/0x248)
> [  326.236612] [<c003fb84>] (__do_softirq+0x118/0x248) from [<c003ff64>] (irq_exit+0x44/0x84)
> [  326.245337] [<c003ff64>] (irq_exit+0x44/0x84) from [<c000e780>] (handle_IRQ+0x7c/0xb8)
> [  326.253693] [<c000e780>] (handle_IRQ+0x7c/0xb8) from [<c000857c>] (omap3_intc_handle_irq+0x54/0x68)
> [  326.263243] [<c000857c>] (omap3_intc_handle_irq+0x54/0x68) from [<c04e2900>] (__irq_svc+0x40/0x50)
> [  326.272687] Exception stack(0xc074bf68 to 0xc074bfb0)
> [  326.278018] bf60:                   ffffffed 00000000 002f8000 00000000 c074a000 c07b6608
> [  326.286640] bf80: c04ec10c c0757618 80004059 413fc082 00000000 00000000 00000000 c074bfb0
> [  326.295262] bfa0: c000e904 c000e908 60000013 ffffffff
> [  326.300601] [<c04e2900>] (__irq_svc+0x40/0x50) from [<c000e908>] (default_idle+0x24/0x2c)
> [  326.309228] [<c000e908>] (default_idle+0x24/0x2c) from [<c000ea7c>] (cpu_idle+0x9c/0xf0)
> [  326.317787] [<c000ea7c>] (cpu_idle+0x9c/0xf0) from [<c06ff7dc>] (start_kernel+0x258/0x2a4)
> 
> It seems lowpan_header_create is calling from a irq context.
> So kzalloc need a GFP_ATOMIC flag instead GFP_KERNEL.
> Also improve a comment codestyle.
> 
> There exist a similar fix for mac802154/wpan.c
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>  net/ieee802154/6lowpan.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index f651da6..bc61d18 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -380,12 +380,13 @@ static int lowpan_header_create(struct sk_buff *skb,
>  	u8 *head;
>  	struct ieee802154_addr sa, da;
>  
> +	/* TODO:
> +	 * if this package isn't ipv6 one, where should it be routed?
> +	 */
>  	if (type != ETH_P_IPV6)
>  		return 0;
> -		/* TODO:
> -		 * if this package isn't ipv6 one, where should it be routed?
> -		 */
> -	head = kzalloc(100, GFP_KERNEL);
> +
> +	head = kzalloc(100, GFP_ATOMIC);
>  	if (head == NULL)
>  		return -ENOMEM;
>  
> -- 
> 1.8.1.2
> 

Please drop this patch, I resend a better solution, similar mac802154 fix.
