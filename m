From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe: panic in ixgbe_clean_rx_irq()
Date: Wed, 22 Jul 2009 11:13:00 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0907221110550.9360@ppwaskie-MOBL2.amr.corp.intel.com>
References: <1248266678.17215.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56914 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752703AbZGVSNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 14:13:00 -0400
In-Reply-To: <1248266678.17215.15.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jul 2009, Jesper Dangaard Brouer wrote:

> Hi Peter,
> 
> Got a panic from the ixgbe driver on my 82599 based NICs, while running
> two pktgen tests (1500 bytes packets) against the machine.
> 
> Kernel: 2.6.31-rc1-net-2.6-00122-ge594e96 with preemption
> 
> The panic occurs in ixgbe_clean_rx_irq+0x319/0x53b
> 
> Using objdump I can see that it seems to occur in an inlined function
> ixgbe_transform_rsc_queue() in objdump "line" "2811:"
> (ixgbe_clean_rx_irq starts 0x24f8 + 0x319 = 0x2811)
> 
> static inline struct sk_buff *ixgbe_transform_rsc_queue(struct sk_buff *skb)
> {
>         unsigned int frag_list_size = 0;
> 
>         while (skb->prev) {
>     2811:       48 8b 7b 08             mov    0x8(%rbx),%rdi
>     2815:       48 85 ff                test   %rdi,%rdi
>     2818:       75 e9                   jne    2803 <ixgbe_clean_rx_irq+0x30b>
>                 frag_list_size += skb->len;
>                 skb->prev = NULL;
>                 skb = prev;
>         }
> 
>         skb_shinfo(skb)->frag_list = skb->next;
>     281a:       48 8b 03                mov    (%rbx),%rax
>     281d:       8b 8b c8 00 00 00       mov    0xc8(%rbx),%ecx
>     2823:       48 8b 93 d0 00 00 00    mov    0xd0(%rbx),%rdx
>     282a:       48 89 44 0a 20          mov    %rax,0x20(%rdx,%rcx,1)
>         skb->next = NULL;
>     282f:       48 c7 03 00 00 00 00    movq   $0x0,(%rbx)
>         skb->len += frag_list_size;
>     2836:       01 73 60                add    %esi,0x60(%rbx)
>         skb->data_len += frag_list_size;
>     2839:       01 73 64                add    %esi,0x64(%rbx)
>         skb->truesize += frag_list_size;
>     283c:       01 b3 e0 00 00 00       add    %esi,0xe0(%rbx)
>                 }
> 
> 
> Let me know if you want the objdump, its quite large.

Thanks for the report Jesper.  Hold onto the objdump for now.  If I need 
it, I'll let you know (and give you a place to upload it to).

For the time being, I have one of my validation guys trying to get a repro 
in our lab right now.  So please consider this being actively worked on 
right now.  Hopefully I'll have something for you soon.

Cheers,
-PJ Waskiewicz
