From: Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be
	misaligned
Date: Thu, 30 Jan 2014 17:17:21 +0100
Message-ID: <20140130161721.25560.qmail@stuge.se>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6B5486@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6B5486-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Laight wrote:
> Some xhci (USB3) controllers have a constraint on the offset within a
> bulk transfer of the end of the transfer ring.

Mhm.


> code using libusb can generate arbitrarily long transfers that usually
> get split into 8k fragments.

libusb splits transfers into 16k urbs, or doesn't with newer code
when both kernel and libusb support scatter-gather.


> In fact libusb always uses 8k fragments.

Hm? Worst-case libusb-1.0 submits 16k urbs. libusb-0.1 I'm unsure
about, but could check.

When both sides support it, scatter-gather is used and a single urb
is submitted.

IIRC usbfs doesn't mess with urb buffers at all.

Where's the 8k coming from?


> This all means that the xhci driver needs to accept unlimited numbers
> of 'aligned' fragments and only restrict the number of misaligned ones.

libusb applications have so far never made efforts to align their
buffers to anything. That seems to become relevant for zero-copy?


//Peter
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
