From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] forcedeth: fix random memory scribbling bug
Date: Sat, 24 Dec 2005 12:41:35 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0512241241230.14098__7181.0805741281$1135457156$gmane$org@g5.osdl.org>
References: <43AD4ADC.8050004@colorfullife.com> <Pine.LNX.4.64.0512241145520.14098@g5.osdl.org>
 <43ADA7D0.9010908@colorfullife.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, Ayaz Abdulla <AAbdulla@nvidia.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <43ADA7D0.9010908@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 24 Dec 2005, Manfred Spraul wrote:

> Linus Torvalds wrote:
> 
> > Of course, on the alloc path, it seems to add an additional
> > "NV_RX_ALLOC_PAD" thing, so maybe the "end-data" thing makes sense.
>
> The problem is the pci_unmap_single() call that happens during nv_close() or
> the rx interrupt handler. I think it makes more sense to rely on fields in the
> individual skb instead of reading from np->rx_buf_sz. If np->rx_buf_sz changes
> inbetween, then we have a memory leak.

Fair enough. Patch applied.

		Linus
