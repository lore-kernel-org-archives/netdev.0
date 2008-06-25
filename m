From: <Mario_Limonciello@Dell.com>
Subject: Re: [BUG or cosmic ray] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0xe8/0x100()
Date: Tue, 24 Jun 2008 23:34:39 -0500
Message-ID: <E6FF208A16840D4EBAA31D261B15A506011CAF8B@ausx3mpc121.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:28851 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbYFYEeu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 00:34:50 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unfortunately, I am running into the same problem on a RTL8102EL.  I
added it to the table locally to ensure it was identifying with the
correct mac_version, (mac_version=0x11).

> If lspci can not read the device registers correctly, chances are high
> that the device driver can not either.
Correct, in my case.

> If you can reproduce the "!!! Unknown header type 7f" error with lspci
> on 2.6.26-rc6 we have a problem which goes beyond the sole r8169
device
> driver. linux-kernel or linux-pci will probably be more helpful than
> netdev then.

Exact same behavior on this end.  It's reproducible in a variety of
ways:
* Randomly on startup, in an invalid state
* After a random resume from S3
* rmmod/modprobe r8169 over and over.  It's important to note that it
breaks on the "modprobe" not on the rmmod.  This can be verified by
checking
Lspci -vvv -nn -d 10ec:8136 in between rmmod and modprobe


If it happens after the  S3, rmmod will cause a kernel panic.

I'm not on 2.6.26-rc6 at this point, but 2.6.24 (the Ubuntu -19 variant)
with the r8169 module compiled out of tree.  If there are indeed other
fixes to the PCI subsystem that are relevant, I'll pull a 2.6.26 kernel,
but in the end need to be able to narrow this down to a small series of
fixes.

> Playing with the pci=nommconf , noapic or nomsi options at boot time
> can make a difference with relation to lspci behavior. It is possible
> (or almost certain given Murphy's grip) that the r8169 driver will
> still not behave correctly. I have not received a lot of
success/failure
> reports for this chipset ([10ec:8136]) so things can surely improve.
These all give the same behavior.  I'm a bit doubtful that it is not
r8169 specific as I've not been able to ever produce this problem with
other network drivers.
