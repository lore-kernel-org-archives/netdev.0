From: Anton Blanchard <anton@samba.org>
Subject: Re: Allow IP header alignment to be overriden
Date: Sat, 12 Jun 2004 00:23:37 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040611142336.GE27672@krispykreme>
References: <20040611012727.GA27672@krispykreme> <20040610223549.5e9ad025.davem@redhat.com> <1086939562.3657.10.camel@sfeldma-mobl2.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <1086939562.3657.10.camel@sfeldma-mobl2.dsl-verizon.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
Hi,

> Would replacing "2" with a macro that's defined on a per-arch basis
> work?

Nice idea. This would avoid us adding useless padding in that case, as
we currently do:

reserve_len = 2;
skb = dev_alloc_skb(adapter->rx_buffer_len + reserve_len);
skb_reserve(skb, reserve_len);

which would be nice if we are using a power of 2 buffer size. Would
creating:

/* 
 * Network drivers want to align IP headers. Since we have 14 bytes of
 * ethernet header, adding 2 bytes will align the IP header.  However
 * this will mean we do unaligned DMA so there is a trade off.
 *
 * We allow this to be overridden per arch as the unaligned DMA cost may
 * outweigh the unaligned CPU cost.
 */
#ifndef NET_IP_ALIGN
#define NET_IP_ALIGN 2
#endif

Instead of skb_align make more sense? It does have the advantage of
removing another magic number.

Anton
