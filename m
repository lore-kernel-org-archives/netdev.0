From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Fri, 19 May 2006 03:55:10 +0200
Message-ID: <200605190355.11230.arnd@arndb.de>
References: <20060517220218.GA13411@myri.com> <200605180108.32949.arnd@arndb.de> <446D0994.8090103@myri.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:20939 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S932204AbWESBzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 21:55:04 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <446D0994.8090103@myri.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Friday 19 May 2006 01:56 schrieb Brice Goglin:
> This place is actually the only one where we don't want to use msleep.
> This function (myri10ge_send_cmd) might be called from various context
> (spinlocked or not) and pass orders to the NIC whose processing time
> depends a lot on the command. Of course, we don't have any place where a
> long operation is passed from a spinlocked context :) But, we need the
> tiny udelay granularity for the spinlocked case, and the long loop for
> operations that are long to process in the NIC.

I don't see any spinlocks in your code and the function does not
seem to be called from the interrupt handler or the softirq either.
Maybe I'm missed something, but where is this ever called in an
atomic context?

> > missing printk level (KERN_DEBUG?). Could probably use dev_printk.
>
> When are we supposed to call dev_printk or not in such a driver ?

Whenever you have a device associated with the message, it makes
sense to use the dev_printk family of functions.

> >> +#define MYRI10GE_PCI_VENDOR_MYRICOM 	0x14c1
> >> +#define MYRI10GE_PCI_DEVICE_Z8E 	0x0008
> >
> > Shouldn't the vendor ID go to pci_ids.h?
>
> That's what I thought but i was told that the fashion these days is to
> keep the IDs with the driver that uses them. I'll happy to move as long
> as everybody agrees :)

My understanding is that vendor IDs should go to the common file
because they are likely to be used by multiple drivers whereas
device IDs only need to be present in the one device driver for
that particular device.

	Arnd <><
