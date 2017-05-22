From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory
 low
Date: Mon, 22 May 2017 15:27:17 +0200
Message-ID: <1495459637.11462.19.camel@suse.com>
References: <1494956480-6127-1-git-send-email-jim_baxter@mentor.com>
         <1494956480-6127-2-git-send-email-jim_baxter@mentor.com>
         <063D6719AE5E284EB5DD2968C1650D6DCFFFAA5C@AcuExch.aculab.com>
         <87pof5rlw4.fsf@miraculix.mork.no>
         <063D6719AE5E284EB5DD2968C1650D6DCFFFAC2B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Jim Baxter' <jim_baxter-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
        =?ISO-8859-1?Q?=27Bj=F8rn?= Mork' <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFFAC2B-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Freitag, den 19.05.2017, 14:46 +0000 schrieb David Laight:
> For XHCI it isn't too bad because it will do arbitrary scatter-gather
> (apart from the ring end).
> But I believe the earlier controllers only support fragments that
> end on usb packet boundaries.
> 
> I looked at the usbnet code a few years ago, I'm sure it ought to
> be possible to shortcut most of the code that uses URB and directly
> write to the xhci (in particular) ring descriptors.

Hi,

we cannot break the layering. URBs can support scatter/gather and
that infrastructure must be used. And usbnet will work with sg used
in skbs. What you should honor in general is not splitting packets.
So 512 byte chunks.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
