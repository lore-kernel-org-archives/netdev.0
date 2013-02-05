From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] wpan: use GFP_ATOMIC instead of GFP_KERNEL
Date: Tue, 5 Feb 2013 19:13:11 +0100
Message-ID: <20130205181310.GB1124@x61s.8.8.8.8>
References: <1360078474-24362-1-git-send-email-alex.aring@gmail.com>
 <1360080597.28557.5.camel@edumazet-glaptop>
 <20130205180057.GA1124@x61s.8.8.8.8>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:38507 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756247Ab3BESM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 13:12:26 -0500
Received: by mail-bk0-f51.google.com with SMTP id ik5so235213bkc.38
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 10:12:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130205180057.GA1124@x61s.8.8.8.8>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Feb 05, 2013 at 07:00:57PM +0100, Alexander Aring wrote:
> Hi,
> 
> thanks for your reply.
> 
> On Tue, Feb 05, 2013 at 08:09:57AM -0800, Eric Dumazet wrote:
> > On Tue, 2013-02-05 at 16:34 +0100, Alexander Aring wrote:
> > > I got this message at runtime:
> > > 
> > > [   48.847347] BUG: scheduling while atomic: swapper/0/0/0x40000100
> > > [   48.853870] Modules linked in: autofs4
> > > [   48.857891] [<c0013db8>] (unwind_backtrace+0x0/0x11c) from [<c04cfb84>] (__schedule_bug+0x48/0x5c)
> > > [   48.867342] [<c04cfb84>] (__schedule_bug+0x48/0x5c) from [<c04e0f4c>] (__schedule+0x68/0x5bc)
> > > [   48.876357] [<c04e0f4c>] (__schedule+0x68/0x5bc) from [<c0063f0c>] (__cond_resched+0x24/0x34)
> > > [   48.885368] [<c0063f0c>] (__cond_resched+0x24/0x34) from [<c04e152c>] (_cond_resched+0x34/0x44)
> > > [   48.894559] [<c04e152c>] (_cond_resched+0x34/0x44) from [<c00e9b28>] (kmem_cache_alloc_trace+0x2c/0x158)
> > > [   48.904578] [<c00e9b28>] (kmem_cache_alloc_trace+0x2c/0x158) from [<c04baa3c>] (mac802154_header_create+0x44/0x2)
> > > [   48.915594] [<c04baa3c>] (mac802154_header_create+0x44/0x24c) from [<c04b8e50>] (lowpan_header_create.part.3+0x7)
> > > [   48.927157] [<c04b8e50>] (lowpan_header_create.part.3+0x734/0x79c) from [<c03ebc04>] (neigh_connected_output+0x9)
> > > [   48.938542] [<c03ebc04>] (neigh_connected_output+0x98/0xd0) from [<c0467d5c>] (ip6_finish_output2+0x374/0x45c)
> > > [   48.949102] [<c0467d5c>] (ip6_finish_output2+0x374/0x45c) from [<c0479bcc>] (ndisc_send_skb+0x174/0x22c)
> > > [   48.959101] [<c0479bcc>] (ndisc_send_skb+0x174/0x22c) from [<c047b138>] (ndisc_send_rs+0x3c/0x44)
> > > [   48.968473] [<c047b138>] (ndisc_send_rs+0x3c/0x44) from [<c046e3f0>] (addrconf_rs_timer+0xbc/0x16c)
> > > [   48.978032] [<c046e3f0>] (addrconf_rs_timer+0xbc/0x16c) from [<c00451fc>] (call_timer_fn+0x74/0x134)
> > > [   48.987675] [<c00451fc>] (call_timer_fn+0x74/0x134) from [<c0046984>] (run_timer_softirq+0x258/0x2d4)
> > > [   48.997417] [<c0046984>] (run_timer_softirq+0x258/0x2d4) from [<c003fb84>] (__do_softirq+0x118/0x248)
> > > [   49.007156] [<c003fb84>] (__do_softirq+0x118/0x248) from [<c003ff64>] (irq_exit+0x44/0x84)
> > > [   49.015890] [<c003ff64>] (irq_exit+0x44/0x84) from [<c000e780>] (handle_IRQ+0x7c/0xb8)
> > > [   49.024249] [<c000e780>] (handle_IRQ+0x7c/0xb8) from [<c000857c>] (omap3_intc_handle_irq+0x54/0x68)
> > > [   49.033801] [<c000857c>] (omap3_intc_handle_irq+0x54/0x68) from [<c04e2900>] (__irq_svc+0x40/0x50)
> > > [   49.043239] Exception stack(0xc074bf68 to 0xc074bfb0)
> > > [   49.048576] bf60:                   ffffffed 00000000 002f8000 00000000 c074a000 c07b6608
> > > [   49.057199] bf80: c04ec10c c0757618 80004059 413fc082 00000000 00000000 00000000 c074bfb0
> > > [   49.065821] bfa0: c000e904 c000e908 60000013 ffffffff
> > > [   49.071162] [<c04e2900>] (__irq_svc+0x40/0x50) from [<c000e908>] (default_idle+0x24/0x2c)
> > > [   49.079789] [<c000e908>] (default_idle+0x24/0x2c) from [<c000ea7c>] (cpu_idle+0x9c/0xf0)
> > > [   49.088328] [<c000ea7c>] (cpu_idle+0x9c/0xf0) from [<c06ff7dc>] (start_kernel+0x258/0x2a4)
> > > 
> > > It seems that mac802154_header_create is calling from a irq context.
> > > So kzalloc need GFP_ATOMIC flag.
> > > 
> > > This patch will fix it.
> > > 
> > > Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> > > ---
> > >  net/mac802154/wpan.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
> > > index 98c867b..0d9e110 100644
> > > --- a/net/mac802154/wpan.c
> > > +++ b/net/mac802154/wpan.c
> > > @@ -143,7 +143,7 @@ static int mac802154_header_create(struct sk_buff *skb,
> > >  	if (!daddr)
> > >  		return -EINVAL;
> > >  
> > > -	head = kzalloc(MAC802154_FRAME_HARD_HEADER_LEN, GFP_KERNEL);
> > > +	head = kzalloc(MAC802154_FRAME_HARD_HEADER_LEN, GFP_ATOMIC);
> > >  	if (head == NULL)
> > >  		return -ENOMEM;
> > >  
> > 
> > Please remove this allocation, its absolutely not needed.
> 
> I don't know how I can do that. head is a temp buffer.
> At the end of this function stands:
> 
> memcpy(skb_push(skb, pos), head, pos)
> 
> and 'pos' is determined at runtime. skb_push will add data to the
> start of buffer, so head buffer will be at the start of skb. I don't
> know where I should manipulate the skb buffer at beginning of this function.
> 
> Regards
> Alex

Ahh, you mean to put it on the stack. :-)

Sorry about that.

> 
> > 
> > 40 bytes on the stack are fine.
> > 
> > Thanks
> > 
> > 
