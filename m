From: Andi Kleen <ak@suse.de>
Subject: Re: Allow IP header alignment to be overriden
Date: Fri, 11 Jun 2004 03:35:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040611013522.GA9809@wotan.suse.de>
References: <20040611012727.GA27672@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
Content-Disposition: inline
In-Reply-To: <20040611012727.GA27672@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The following patch creates skb_align and allows an architecture to
> override it. Thoughts?

I like it. While we haven't seen specific networking performance issues
on Opteron yet it's certainly one architectures that doesn't care much
about misalignment. The Intel EM64T CPUs have a bit more penalty, but
also not much. It's certainly one optimization worth trying.

> + *	skb_align - align a buffer
> + *	@skb: buffer to alter
> + *	@len: bytes required to align
> + *
> + * 	Shift a buffer by len bytes for the purposes of alignment. On
> + * 	some architectures that handle unaligned accesses in hardware
> + * 	the effects of unaligned DMA is more costly so we allow it to
> + * 	be overridden. This is only allowed for an empty buffer.
> + */
> +#ifndef ARCH_HAS_SKB_ALIGN
> +#define skb_align(SKB, LEN)	skb_reserve((SKB), (LEN))
> +#endif

But where does this come from? There's no clear asm/ include in skbuff.h
matching it, and relying on indirect ones is probably not a good idea.

-Andi
