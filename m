From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: e1000 question
Date: Wed, 2 Jun 2004 03:30:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602103027.GA74881@gaz.sfgoth.com>
References: <40BD8E49.3070605@giga-stream.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ihar 'Philips' Filipau" <ifilipau@giga-stream.de>
Content-Disposition: inline
In-Reply-To: <40BD8E49.3070605@giga-stream.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ihar 'Philips' Filipau wrote:
>    Functions e1000_clean_{t,r}x_irq are very similar: both of them are 
> checking descriptor flag updated by nic.
>    Host CPU, obviously, to perform this check, will cache descriptor.
>    If, say e1000_clean_rx_irq() will be called twice in short time 
> range, I expect that it can miss change of the flag, since old flag may 
> still sit in host CPU cache.

Please see Documentation/DMA-mapping.txt; especially the part starting
at "There are two types of DMA mappings..."  Ring buffers are allocated
as "consistent" DMA memory.

For most architectures this will mean that the cache hardware snoops the
PCI bus and automatically invalidates cache lines as they are written to.
For architectures that can't do that then Linux will mark those memory
regions uncacheable.

-Mitch
