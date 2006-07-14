From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-rc1-mm2
Date: Fri, 14 Jul 2006 00:05:51 -0700
Message-ID: <20060714000551.649ca455.akpm@osdl.org>
References: <20060713224800.6cbdbf5d.akpm@osdl.org>
	<44B73FEE.6040908@reub.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45805 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161049AbWGNHGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 03:06:09 -0400
To: Reuben Farrelly <reuben-lkml@reub.net>
In-Reply-To: <44B73FEE.6040908@reub.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Jul 2006 18:55:42 +1200
Reuben Farrelly <reuben-lkml@reub.net> wrote:

> On 14/07/2006 5:48 p.m., Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc1/2.6.18-rc1-mm2/
> > 
> > - Patches were merged, added, dropped and fixed.  Nothing particularly exciting.
> > 
> > - Added the avr32 architecture.  Review is sought, please.
> 
> Ugh.  This on bootup..
> 
> Starting HAL daemon: BUG: warning at net/core/dev.c:1171/skb_checksum_help()
> 
> Call Trace:
>   [<ffffffff8026963e>] show_trace+0xae/0x265
>   [<ffffffff8026980a>] dump_stack+0x15/0x1b
>   [<ffffffff8043ba7b>] skb_checksum_help+0x61/0x126
>   [<ffffffff8802f35f>] :iptable_nat:ip_nat_fn+0x5f/0x1d2
>   [<ffffffff8802f71b>] :iptable_nat:ip_nat_local_fn+0x33/0xbc
>   [<ffffffff80234c6e>] nf_iterate+0x5a/0x9b
>   [<ffffffff802588d0>] nf_hook_slow+0x60/0xcd
>   [<ffffffff8023511a>] ip_queue_xmit+0x41a/0x490
>   [<ffffffff80221507>] tcp_transmit_skb+0x697/0x6d4
>   [<ffffffff80233b37>] __tcp_push_pending_frames+0x867/0x95b
>   [<ffffffff80226546>] tcp_sendmsg+0xa76/0xba6
>   [<ffffffff80245c49>] inet_sendmsg+0x46/0x53
>   [<ffffffff80247ebf>] sock_aio_write+0x13b/0x15c
>   [<ffffffff8021758c>] do_sync_write+0xec/0x135
>   [<ffffffff802160b5>] vfs_write+0xe5/0x180
>   [<ffffffff80216ade>] sys_write+0x47/0x79
>   [<ffffffff8025f3a2>] system_call+0x7e/0x83
>   [<00002b145e465350>]
> BUG: warning at net/core/dev.c:1225/skb_gso_segment()

int skb_checksum_help(struct sk_buff *skb, int inward)
{
	unsigned int csum;
	int ret = 0, offset = skb->h.raw - skb->data;

	if (inward)
		goto out_set_summed;

	if (unlikely(skb_shinfo(skb)->gso_size)) {
		static int warned;

		WARN_ON(!warned);

That's a mainline problem, I suspect.
