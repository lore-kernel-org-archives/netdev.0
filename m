From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH staging] Add SBE 2T3E3 WAN driver
Date: Sun, 01 Aug 2010 15:23:21 +0200
Message-ID: <m31vai1n7a.fsf@intrepid.localdomain>
References: <m3ocdoasen.fsf@intrepid.localdomain>
	<20100731195335.GB4644@kroah.com>
	<m362zv5oet.fsf@intrepid.localdomain>
	<20100801002713.GA6751@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:39593 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756421Ab0HANXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Aug 2010 09:23:23 -0400
In-Reply-To: <20100801002713.GA6751@kroah.com> (Greg KH's message of "Sat, 31
	Jul 2010 17:27:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <greg@kroah.com> writes:

>> These entries are also needed for the tulip Ethernet driver, to avoid
>> initializing these ports (they are using Tulip DECchips with custom FPGA
>> for HDLC). I posted a patch on netdev list.
>
> Then make the patch part of that submission, I can't add non-staging
> patches to the drivers/staging/ tree if at all possible.

I did, I just didn't want a dependency and thus the change to
pci_ids.h is present in both patches, with the assumption git will take
care of it when merging.

>> The main reason is the interface ("PRIVATE" netdev ioctls) for
>> controlling the hdlcX devices is not stable. The plan is to write a new
>> user-kernel interface for generic HDLC, this driver (and other ones)
>> will then use it. For now, there is a separate utility from SBE for this
>> card.
>
> Ah, ick.  Is this going to be fixed up anytime soon?

Well, I hope so. Depends on the definition of "soon", though. Something
like several months, realistically.

> Care to respin this with the TODO file?`

Will do, sure.

> And look, you do have a copy of the file, right there.  Care to post it
> somewhere?  We need to see the license and other markings on it to know
> about this driver, right?  Where did you get it from?

I got it from a friend along with a card. That's exactly what they
received from SBE. It's a driver for older Linux only, something like
up to 2.6.20 maybe. I'm told they have no newer version (i.e. working
with newer kernels; they may have a version with the new company name).

SBE (embedded devices division?) doesn't exist anymore, but this
particular piece of hardware is there:

http://www.onestopsystems.com/communication_wan_f.php

I posted the driver here:
http://userweb.kernel.org/~chris/SBE_2T3_Linux_2.0c.tgz

>> It seems the DRV_NAME is only used for various printk() and for
>> pci_request_regions(). Does it still cause problems?
>
> It's not nice, hopefully you can fix it up.  Well, remove it entirely
> would be good, but you can add that to the TODO file :)

Ah, doing a simple search & replace isn't a problem for me. Just wanted
to confirm it's not nice.

Will post a revised patch shortly, of course.
-- 
Krzysztof Halasa
