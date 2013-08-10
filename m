From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] skge: add dma_mapping check
Date: Sat, 10 Aug 2013 10:41:00 -0700
Message-ID: <20130810104100.0ae20aa6@nehalam.linuxnetplumber.net>
References: <20130804172234.345913ae@nehalam.linuxnetplumber.net>
	<20130804.183553.514470399074672614.davem@davemloft.net>
	<52062955.90102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:58468 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491Ab3HJRlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 13:41:06 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so5479616pbc.35
        for <netdev@vger.kernel.org>; Sat, 10 Aug 2013 10:41:05 -0700 (PDT)
In-Reply-To: <52062955.90102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 10 Aug 2013 13:51:49 +0200
poma <pomidorabelisima@gmail.com> wrote:

> On 05.08.2013 03:35, David Miller wrote:
> > From: Stephen Hemminger <stephen@networkplumber.org>
> > Date: Sun, 4 Aug 2013 17:22:34 -0700
> > 
> >> This old driver never checked for DMA mapping errors.
> >> Causing splats with the new DMA mapping checks:
> >> 	WARNING: at lib/dma-debug.c:937 check_unmap+0x47b/0x930()
> >> 	skge 0000:01:09.0: DMA-API: device driver failed to check map
> >>
> >> Add checks and unwind code.
> >>
> >> Reported-by: poma <pomidorabelisima@gmail.com>
> >> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > 
> > Applied, but:
> > 
> >> -static void skge_rx_setup(struct skge_port *skge, struct skge_element *e,
> >> +static int skge_rx_setup(struct skge_port *skge, struct skge_element *e,
> >>  			  struct sk_buff *skb, unsigned int bufsize)
> > 
> > I reflowed the argument indentation for this in the final commit.
> > 
> > Thanks.
> > 
> 
> skge-add-dma_mapping-check.patch
> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/patch/drivers/net/ethernet/marvell?id=136d8f377e1575463b47840bc5f1b22d94bf8f63
> 
> /usr/lib/modules/3.11.0-0.rc4.git2.1.fc20.x86_64/updates/skge.ko
> 
> skge: module verification failed: signature and/or required key missing
> - tainting kernel
> skge: 1.14 addr 0xfbffc000 irq 19 chip Yukon rev 1
> skge 0000:01:09.0 eth0: addr nn:nn:nn:nn:nn:nn
> skge 0000:01:09.0 enp1s9: enabling interface
> skge 0000:01:09.0 enp1s9: Link is up at 1000 Mbps, full duplex, flow
> control both
> IPv6: ADDRCONF(NETDEV_CHANGE): enp1s9: link becomes ready
> 
> Starting Nmap 6.25
> 
> ------------[ cut here ]------------
> WARNING: CPU: 2 PID: 2443 at lib/dma-debug.c:986 check_sync+0x4bc/0x580()
> skge 0000:01:09.0: DMA-API: device driver tries to sync DMA memory it
> has not allocated [device address=0x00000000cf390040] [size=60 bytes]
> Modules linked in: skge(OF) raid1 nouveau video mxm_wmi i2c_algo_bit
> drm_kms_helper ttm drm i2c_core wmi
> CPU: 2 PID: 2443 Comm: nmap Tainted: GF          O
> 3.11.0-0.rc4.git2.1.fc20.x86_64 #1
> Hardware name: Gigabyte Technology Co., Ltd. M720-US3/M720-US3, BIOS F7n
> 09/07/2010
>  0000000000000009 ffff88012aa03c48 ffffffff81723ac3 ffff88012aa03c90
>  ffff88012aa03c80 ffffffff8107462d ffff88012837c2b0 000000000000003c
>  ffff880128363470 00000000cf390040 ffff880126f79160 ffff88012aa03ce0
> Call Trace:
>  <IRQ>  [<ffffffff81723ac3>] dump_stack+0x54/0x74
>  [<ffffffff8107462d>] warn_slowpath_common+0x7d/0xa0
>  [<ffffffff8107469c>] warn_slowpath_fmt+0x4c/0x50
>  [<ffffffff81392a5c>] check_sync+0x4bc/0x580
>  [<ffffffff8138519e>] ? debug_check_no_obj_freed+0x14e/0x250
>  [<ffffffff81392b6b>] debug_dma_sync_single_for_cpu+0x4b/0x50
>  [<ffffffff810e6b6c>] ? trace_hardirqs_on_caller+0xac/0x1c0
>  [<ffffffff815d9390>] ? build_skb+0x30/0x1d0
>  [<ffffffff815db349>] ? __netdev_alloc_skb+0x89/0xf0
>  [<ffffffffa01c7e21>] skge_poll+0x3a1/0x9f0 [skge]
>  [<ffffffff815edb41>] ? net_rx_action+0xa1/0x380
>  [<ffffffff815edc12>] net_rx_action+0x172/0x380
>  [<ffffffff8107b4a7>] __do_softirq+0x107/0x410
>  [<ffffffff8107b985>] irq_exit+0xc5/0xd0
>  [<ffffffff81738c16>] do_IRQ+0x56/0xc0
>  [<ffffffff8172d432>] common_interrupt+0x72/0x72
>  <EOI>  [<ffffffff81721f92>] ? __slab_alloc+0x4c2/0x526
>  [<ffffffff810e6bbd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
>  [<ffffffff815db08e>] ? __alloc_skb+0x7e/0x2b0
>  [<ffffffff811d2d71>] __kmalloc_node_track_caller+0x1a1/0x410
>  [<ffffffff815db08e>] ? __alloc_skb+0x7e/0x2b0
>  [<ffffffff815da8a1>] __kmalloc_reserve.isra.25+0x31/0x90
>  [<ffffffff815db08e>] __alloc_skb+0x7e/0x2b0
>  [<ffffffff815d754e>] sock_alloc_send_pskb+0x27e/0x400
>  [<ffffffff815d76e5>] sock_alloc_send_skb+0x15/0x20
>  [<ffffffff816614af>] raw_sendmsg+0x74f/0xc50
>  [<ffffffff81660e7d>] ? raw_sendmsg+0x11d/0xc50
>  [<ffffffff8130246d>] ? avc_has_perm_flags+0x16d/0x350
>  [<ffffffff81302329>] ? avc_has_perm_flags+0x29/0x350
>  [<ffffffff810b797f>] ? local_clock+0x5f/0x70
>  [<ffffffff810e3fcf>] ? lock_release_holdtime.part.28+0xf/0x1a0
>  [<ffffffff816723a7>] inet_sendmsg+0x117/0x230
>  [<ffffffff81672295>] ? inet_sendmsg+0x5/0x230
>  [<ffffffff815d0939>] sock_sendmsg+0x99/0xd0
>  [<ffffffff810e346d>] ? trace_hardirqs_off+0xd/0x10
>  [<ffffffff810e9738>] ? lock_release_non_nested+0x308/0x350
>  [<ffffffff811312e7>] ? rcu_irq_exit+0x77/0xc0
>  [<ffffffff8172d4f3>] ? retint_restore_args+0x13/0x13
>  [<ffffffff815d0e94>] SYSC_sendto+0x124/0x1d0
>  [<ffffffff817369c5>] ? sysret_check+0x22/0x5d
>  [<ffffffff810e6bbd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
>  [<ffffffff8137af2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>  [<ffffffff815d1ffe>] SyS_sendto+0xe/0x10
>  [<ffffffff81736999>] system_call_fastpath+0x16/0x1b
> ---[ end trace ef4521ca4028fd28 ]---

The DMA debug check insists that the call to sync_single has
to be the same length as the mapping. The driver is only bothering
to sync the bytes that matter (got received) rather than the whole
map.

In reality that is not required, but I will make a patch anyway.
