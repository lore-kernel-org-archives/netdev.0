From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH staging] Add SBE 2T3E3 WAN driver
Date: Sat, 31 Jul 2010 17:27:13 -0700
Message-ID: <20100801002713.GA6751@kroah.com>
References: <m3ocdoasen.fsf@intrepid.localdomain> <20100731195335.GB4644@kroah.com> <m362zv5oet.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:48402 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751850Ab0HAA3z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 20:29:55 -0400
Content-Disposition: inline
In-Reply-To: <m362zv5oet.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 31, 2010 at 11:31:22PM +0200, Krzysztof Halasa wrote:
> Greg KH <greg@kroah.com> writes:
> 
> >>  include/linux/pci_ids.h              |    3 +
> >
> > First off, read the top of the pci_ids.h file, which says to not add new
> > entries that are only used in a single driver.
> 
> These entries are also needed for the tulip Ethernet driver, to avoid
> initializing these ports (they are using Tulip DECchips with custom FPGA
> for HDLC). I posted a patch on netdev list.

Then make the patch part of that submission, I can't add non-staging
patches to the drivers/staging/ tree if at all possible.

> > Secondly, why have this as a staging driver?  What is lacking in it to
> > get it merged into the main kernel tree as a "normal" driver?
> 
> The main reason is the interface ("PRIVATE" netdev ioctls) for
> controlling the hdlcX devices is not stable. The plan is to write a new
> user-kernel interface for generic HDLC, this driver (and other ones)
> will then use it. For now, there is a separate utility from SBE for this
> card.

Ah, ick.  Is this going to be fixed up anytime soon?

> > Hint, you
> > need a TODO file in the driver directory that lists the things left to
> > be done to it to get it merged, and a name/email address to send the
> > patches to.
> 
> Ok.

Care to respin this with the TODO file?`

> >> + * This code is based on a driver written by SBE Inc.
> >
> > What driver would that have been?  If it's based on someone else's work,
> > it's nice to mention the copyright holders of that work you based yours
> > on.
> 
> I don't have any details, I'm only told the driver is open-source and
> the file name starts with SBE. No copyright notices except this one:
> 
> $ grep LIC *
> linux_sbe2t3e3.c:MODULE_LICENSE("GPL");

Wait, you wrote this driver, yet you don't have any details about the
driver you based it on?  That makes absolutely no sense.  Please
clarify.

And look, you do have a copy of the file, right there.  Care to post it
somewhere?  We need to see the license and other markings on it to know
about this driver, right?  Where did you get it from?

> BTW SBE Inc. (division?) has been acquired by One Stop Systems, they
> seem to still sell this hw, but I can't see any drivers available for
> downloading (though they mention "open source Linux drivers").

Any links would be appreciated.

> >> +#define DRV_NAME "SBE 2T3E3"
> >
> > spaces and all caps isn't the nicest thing for linux drivers, it does
> > odd things in sysfs for some scripts (the space thing, not the
> > uppercase.)
> 
> It seems the DRV_NAME is only used for various printk() and for
> pci_request_regions(). Does it still cause problems?

It's not nice, hopefully you can fix it up.  Well, remove it entirely
would be good, but you can add that to the TODO file :)

thanks,

greg k-h
