From: Artem Savkov <artem.savkov@gmail.com>
Subject: Re: [PATCH] net: tcp: ipv6_mapped needs sk_rx_dst_set method
Date: Sun, 19 Aug 2012 12:11:38 +0400
Message-ID: <20120819081137.GA4110@thinkpad.lan>
References: <20120809160349.d2880b5a.akpm@linux-foundation.org>
 <1344556733.31104.819.camel@edumazet-glaptop>
 <1344557460.31104.863.camel@edumazet-glaptop>
 <20120809.210600.638327100706973152.davem@davemloft.net>
 <20120818130642.GA10680@thinkpad.lan>
 <CADVnQyn-aDMDdb_nfFyZPtmnKkuFtjwfSNWudnhMdYZz7Ddh7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:61706 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab2HSILp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 04:11:45 -0400
Received: by lbbgj3 with SMTP id gj3so2845974lbb.19
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 01:11:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CADVnQyn-aDMDdb_nfFyZPtmnKkuFtjwfSNWudnhMdYZz7Ddh7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 19, 2012 at 12:06:33AM -0400, Neal Cardwell wrote:
> On Sat, Aug 18, 2012 at 9:06 AM, Artem Savkov <artem.savkov@gmail.com> wrote:
> > [ 1699.195040] EIP is at inet6_sk_rx_dst_set+0x40/0xa0
> ...
> > [ 1699.198736]  [<c15662a1>] tcp_create_openreq_child+0x41/0x4e0
> > [ 1699.198884]  [<c1563b54>] tcp_v4_syn_recv_sock+0x34/0x330
> > [ 1699.199032]  [<c15d162e>] tcp_v6_syn_recv_sock+0x3fe/0x660
> ...
> > [ 1699.242913] EIP: [<c15d11d0>] inet6_sk_rx_dst_set+0x40/0xa0 SS:ESP 0068:f540dce0
> > [ 1699.245945] CR2: 0000000000000016
> > [ 1699.280708] ---[ end trace 3fb05aeec95e7238 ]---
> > [ 1699.280806] Kernel panic - not syncing: Fatal exception in interrupt
> > [ 1699.284674] panic occurred, switching back to text console
> Thanks for the detailed report!
> 
> I don't think that particular fix is kosher, since this basically
> changes the address family ops of the parent listening socket ('sk'
> here).The parent listening socket needs to keep its IPv6 af_ops so its
> IPv6 children can get the right af_ops.
Indeed, my approach breaks ipv6 after first mapped connection.

> We should probably either: (a) make sure the af_ops of the child
> socket are set correctly earlier, or (b) not use dynamic dispatch
> through the af_ops within tcp_create_openreq_child(), and just do the
> sk_rx_dst_set a tiny bit later. I've sent out a patch for approach (b)
> here, since it's simpler:
> 
>   http://patchwork.ozlabs.org/patch/178525/
> 
> I've verified that IPv4, IPv6, and IPv4-mapped-IPv6 connections work
> for me with this patch. But if you could test it as well, that would
> be great.

I've tested it and can confirm that all three connection types work.
Thank you for the patch and explanation.

-- 
Kind regards,
Artem
