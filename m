From: Steve.Glendinning@smsc.com
Subject: Re: Extend smc911x to support LAN921x chips - differences?
Date: Tue, 9 Sep 2008 16:26:35 +0100
Message-ID: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1264 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754786AbYIIP1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 11:27:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guennadi,

> I have to support the LAN9215 chip from SMSC under Linux. Of course, 
there 
> is the manufacturer provided smsc911x driver, that supports both chip 
> families, but I would prefer to extend the mainline smc911x driver to 
also 
> support 921x. I have both datasheets, they are freely downloadable from 
> SMSC site, and I have both drivers, but they are absolutely different. 
To 
> make my decision and the work easier - maybe someone knows from the top 
of 
> their head, what the relevant differences between the chips are?
> 
> The vendor driver does not really differentiate between the chips. It 
does 
> read the chip version, and sets the "generation" variable, but then that 

> variable is only used once to rule out the oldest chips, which anyway 
are 
> not supported by smc911x. So I tried the in-kernel driver with only 
added 
> chip IDs added, it can access registers, read and write the MAC-address, 

> interrupts are generated too, but so far I see nothing on the wire, and 
> the PHY reports "link down".

Did you have the in-tree driver succesfully working with LAN9115?

The only hardware difference between the two is that LAN921[5678] has an
Auto-MDIX PHY.  This adds a configuration bit in one of the 
vendor-specific
PHY registers to force the feature off, but it defaults to Auto-MDIX 
enabled.
All of the SCR and MAC registers (and the remaining PHY registers) are 
*identical*, so any working driver should just need the ID register
changing to recognise the newer part.

Early revisions of LAN911X had a hardware bug which is most commonly
experienced when joining/leaving multicast groups.  The smsc911x driver
contains a workaround for this, but the in-tree driver does not.  LAN921X
came after this was fixed in hardware, so this workaround is not 
necessary.

The vast majority of users i've worked with have ended up using the
out-of-tree smsc911x driver, as it "just works" on many platforms.
I'll be re-submitting another candidate when I've finished working on the
LAN9500 USB ethernet driver, but for now the latest submission:

http://marc.info/?l=linux-netdev&m=121240395122475&w=2

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com

