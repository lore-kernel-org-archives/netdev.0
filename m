From: Anton Blanchard <anton@samba.org>
Subject: Re: Allow IP header alignment to be overriden
Date: Fri, 11 Jun 2004 11:43:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040611014355.GB27672@krispykreme>
References: <20040611012727.GA27672@krispykreme> <20040611013522.GA9809@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040611013522.GA9809@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> > +#ifndef ARCH_HAS_SKB_ALIGN
> > +#define skb_align(SKB, LEN)	skb_reserve((SKB), (LEN))
> > +#endif
> 
> But where does this come from? There's no clear asm/ include in skbuff.h
> matching it, and relying on indirect ones is probably not a good idea.

Yeah I wasnt particularly happy about where I put the override.
skbuff.h directly includes:

#include <asm/atomic.h>
#include <asm/types.h>

...

#include <asm/system.h>

system.h gets included way down in the file, so I picked system.h as the 
most reasonable of the three. Im open to ideas as to how to make this neater.

Anton
