From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH staging] Add SBE 2T3E3 WAN driver
Date: Sat, 31 Jul 2010 23:31:22 +0200
Message-ID: <m362zv5oet.fsf@intrepid.localdomain>
References: <m3ocdoasen.fsf@intrepid.localdomain>
	<20100731195335.GB4644@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57796 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072Ab0GaVbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 17:31:25 -0400
In-Reply-To: <20100731195335.GB4644@kroah.com> (Greg KH's message of "Sat, 31
	Jul 2010 12:53:35 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <greg@kroah.com> writes:

>>  include/linux/pci_ids.h              |    3 +
>
> First off, read the top of the pci_ids.h file, which says to not add new
> entries that are only used in a single driver.

These entries are also needed for the tulip Ethernet driver, to avoid
initializing these ports (they are using Tulip DECchips with custom FPGA
for HDLC). I posted a patch on netdev list.

> Secondly, why have this as a staging driver?  What is lacking in it to
> get it merged into the main kernel tree as a "normal" driver?

The main reason is the interface ("PRIVATE" netdev ioctls) for
controlling the hdlcX devices is not stable. The plan is to write a new
user-kernel interface for generic HDLC, this driver (and other ones)
will then use it. For now, there is a separate utility from SBE for this
card.

> Hint, you
> need a TODO file in the driver directory that lists the things left to
> be done to it to get it merged, and a name/email address to send the
> patches to.

Ok.

>> + * This code is based on a driver written by SBE Inc.
>
> What driver would that have been?  If it's based on someone else's work,
> it's nice to mention the copyright holders of that work you based yours
> on.

I don't have any details, I'm only told the driver is open-source and
the file name starts with SBE. No copyright notices except this one:

$ grep LIC *
linux_sbe2t3e3.c:MODULE_LICENSE("GPL");

BTW SBE Inc. (division?) has been acquired by One Stop Systems, they
seem to still sell this hw, but I can't see any drivers available for
downloading (though they mention "open source Linux drivers").

>> +#define DRV_NAME "SBE 2T3E3"
>
> spaces and all caps isn't the nicest thing for linux drivers, it does
> odd things in sysfs for some scripts (the space thing, not the
> uppercase.)

It seems the DRV_NAME is only used for various printk() and for
pci_request_regions(). Does it still cause problems?
-- 
Krzysztof Halasa
