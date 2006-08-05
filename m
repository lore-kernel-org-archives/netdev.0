From: Jason Lunz <lunz@falooley.org>
Subject: Re: e100: checksum mismatch on 82551ER rev10
Date: Sat, 5 Aug 2006 17:21:57 +0000 (UTC)
Message-ID: <eb2k3k$qnd$1@sea.gmane.org>
References: <44D0D7CA.2060001@intel.com> <62b0912f0608040404p59545a0asc7f5fc5f537ec32c@mail.gmail.com> <20060804.042024.63108922.davem@davemloft.net> <20060804.042834.78730901.davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:34221 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1030257AbWHERWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2006 13:22:16 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1G9Pqf-0001HO-3X
	for netdev@vger.kernel.org; Sat, 05 Aug 2006 19:22:05 +0200
Received: from adsl-065-013-029-145.sip.asm.bellsouth.net ([65.13.29.145])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2006 19:22:05 +0200
Received: from lunz by adsl-065-013-029-145.sip.asm.bellsouth.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2006 19:22:05 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

davem@davemloft.net said:
> And BTW I want to remind the entire world that the last time Intel
> cried wolf to all of us about vendors using broken EEPROMs with their
> networking chips it turned out to be a bug in one of the patches Intel
> put into the Linux driver. :-)
>
> Intel should really humble themselves and help users instead of hinder
> them.  Putting the blame on other vendors does not help users, I don't
> care how you spin it.  It only serves to make Intel look like a bunch
> of control freaks, and that pisses off users to no end.

The real problem here is neither Intel nor users. It's crappy vendor
QA.  I recently had to deal with a batch of e1000 cards that had the
*wrong* EEPROMs, with *correct* checksums.

So of course the driver didn't complain - nevermind the fact that the
EEPROMs might claim you have a copper card when it's really fiber. And
that's best case, because it fails obviously. Far worse is when an
EEPROM is close enough to "work", but claim the wrong chipset revision
and cause the driver to do totally wrong things in strange
circumstances.

I think this is what Auke is worried about. If you can't trust the
EEPROM, all sorts of maddeningly subtle things can go wrong. And it
isn't likely to be properly diagnosed by an end user.

The sad thing is that the checksum can only protect against a subset of
EEPROM problems. But it does help. As a counterexample, a power failure
last weekend corrupted the EEPROM of the onboard e100 in one of my
servers, and this EEPROM check led to an immediate diagnosis of the
problem.

> Please put the option into the e100 driver to allow trying to use the
> device even if the EEPROM checksum is wrong.

There is already support for EEPROM read/write in ethtool. I used it to
fix the e1000 cards in question. If e100 implements ethtool -E, all
that's needed is documentation on where in the EEPROM the checksum is
stored and how to calculate it. I don't doubt the freely-available pdfs
for e100 chipsets cover this.

Jason

