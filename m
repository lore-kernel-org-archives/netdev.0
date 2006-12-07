From: Dan Williams <dcbw@redhat.com>
Subject: Re: Marvell Libertas wifi
Date: Thu, 07 Dec 2006 16:37:00 -0500
Message-ID: <1165527420.5482.26.camel@localhost.localdomain>
References: <a728f9f90612070932x72e1d25u82ed3ea92984ccfc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45197 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163414AbWLGVez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 16:34:55 -0500
To: Alex Deucher <alexdeucher@gmail.com>
In-Reply-To: <a728f9f90612070932x72e1d25u82ed3ea92984ccfc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-07 at 12:32 -0500, Alex Deucher wrote:
> I just wanted to check on the status of the libertas driver from
> Marvell for the OLPC project.  I haven't really been able to find out

The driver needs quite a bit of love.  It's only been used for embedded
devices so far and has quite a few NDIS-isms sprinkled throughout.  It's
also something like 30,000 LoC, which is completely bogus.  There's no
reason it should be that large given that it's a FullMAC-type part.

We're slowly working on cleaning it up for submission to the kernel.
That process will probably take until after the holidays.  We are
removing unused code/defines, cleaning up WEXT compliance, making
operations like association and scanning asynchronous, converting
private IOCTLs to debugfs, fixing the power-saving code, and adding
draft 802.11s wireless mesh functionality to the firmware and the
driver.

Are you developing a device based on the 8388?  AFAIK, the chip does not
appear in any consumer devices that are generally available to the
public, and certainly isn't sold to Linksys or DLink for consumer USB
dongles.  It does show up in embedded situations like the Nokia N80
mobile phone and a few other small gadgets like that.

> much about this driver other than the commits to the olpc and
> infradead libertas git trees.  The olpc laptop uses the usb interface

Correct; the 8388 module is connected directly to the USB traces coming
out of the 5536 Geode companion chip on the OLPC motherboard.

> and that seems to be what is supported at the moment (although some
> comments in the code allude to pci and sdio interfaces as well).  Does

Yes; the part evidently has other interface variants, though code for
those variants was not provided in the initial driver sources which
Marvell GPL-ed in April.

> anyone know what the plan is for merging this driver into mainline?
> What about pci support?  Did Marvell donate any code for the PCI
> interface? If not how hard would it be to add PCI support?  I

No code for PCI was donated, and we don't have any 8388 PCI cards at
OLPC.

> requested databooks from Marvell months ago, but never got anywhere.
> I'd like to see better support for this chip and would be willing to
> help out.  Any updates would be much appreciated.

Be aware that I _think_ there are a few chips in the Libertas line; we
are using the 8388.  The current driver only supports that specific
part.

That said, if you've got hardware, we'd love patches, certainly accept
patches that provided PCI support and fixed bugs in the driver.  We may
also be able to provide USB 8388 reference dongles for people willing to
help out with the development of the driver.

Cheers,
Dan

> Thanks,
> 
> Alex
> 
> PS, please CC: me on replies as I'm not on this list.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

