From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH] usb: hcd: warn about URB buffers that are not DMA
 aligned and are about to be DMA mapped
Date: Sat, 15 Jun 2013 15:41:04 +0800
Message-ID: <CACVXFVM4TsS-_qK_w01oajV1XcA_+OF8xdTX2xjjxOTFNAo6Sw@mail.gmail.com>
References: <20130614133803.25747.98705.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130614133803.25747.98705.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Cc: netdev

On Fri, Jun 14, 2013 at 9:38 PM, Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org> wrote:
> Appearently some out-of-tree USB host drivers do not handle DMA alignment for

Looks these host drivers have to face the fact that the transfer buffer is often
DMA non-aligned from network device drivers(in fact, the buffer is from
network protocol stack), if you run usbnet, then you will get the added warning
immediately.

> URB buffers and let core/hcd.c to do the mapping on architectures that have
> minimum DMA alignment requirements. This leads to random memory corruptions
> and crashes when using USB device drivers that use unaligned URB buffers.

Maybe you should check the dma mapping/unmapping implementation of
the arch, non-aligned buffer should have be covered by the API easily.

Also USB Host controller should have supported non-aligned DMA buffer.

>
> Instead of fixing host drivers, users end up posting bug reports against
> those USB device drivers that use unaligned buffers for URB; such as with
> rtl8192cu (http://thread.gmane.org/gmane.linux.kernel.wireless.general/105631).

Not only rtl8192cu driver, all USB network device drivers have the problem.

>
> Patch makes this issue more visible at core level, and hopefully gives hint
> for future hcd driver implementors about this problem.

So please find the root cause first, and don't add the noise now.


Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
