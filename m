From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 26/72] arm: Move the ARM/ACORN drivers
Date: Sat, 25 Jun 2011 18:59:38 +0200
Message-ID: <201106251859.38963.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <201106251803.53416.arnd@arndb.de> <20110625161227.GJ23234@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Sriram <srk@ti.com>,
	Vinay Hegde <vinay.hegde@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Anant Gole <anantgole@ti.com>,
	Chaithrika U S <chaithrika@ti.com>
To: "Russell King - ARM Linux" <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:58923 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778Ab1FYQ7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 12:59:44 -0400
In-Reply-To: <20110625161227.GJ23234@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Russell King - ARM Linux wrote:
> 
> How do you deal with NE2K or 8390 stuff, where you have a design which
> has been cloned by many different manufacturers?  Who's do you decide
> to put it in?
> 
> More interestingly, if you have one of the 8390 clones, which directory
> do you look in?  And shouldn't etherh.c live along side 8390's files
> as etherh is 8390-derived?

Jeff created a drivers/net/ethernet/8390/ directory for all of those,
which sounds sensible to me, but apparently he missed some of the
nonobvious ones.

> ether1 is 82586, so presumably that should be Intel subdirectory.

Yes, according to the new layout, it should at least live together
with the other 82586-based drivers (eexpress.c, ni52.c, sun3_82586.c),
which could be either a directory for all of these, or the
generic intel directory.

> ether3 is SEEQ8005, so that should be in the SEEQ subdirectory.

Same here, it can be grouped together with sqiseeq.c (SEEQ8003)
and seeq8005.c.

I don't really care about these old ones too much though. Nobody
will spend the effort to clean up and merge these ancient drivers
any more, and it's also very unlikely that we want to add support
for new boards with these. For the soc vendor specific ones,
I think we should decide on the new location based on how easy it
is to spot duplicates, e.g. to avoid adding an AVR32 copy of the
at91 ethernet driver.

For reference (since you probably didn't see the full 72 patch
series on netdev), some of the related driver moves suggested
by Jeff are:

drivers/net/{ => ethernet/8390}/*8390*.c           |    0
drivers/net/{ => ethernet/amd}/*lance.c            |    0
drivers/net/{ => ethernet/atmel}/macb.c            |    0
drivers/net/{ => ethernet/micrel}/ks8842.c         |    0
drivers/net/{ => ethernet/micrel}/ks8851.c         |    0
drivers/net/{ => ethernet/ti}/cpmac.c              |    0
drivers/net/{ => ethernet/ti}/tlan.c               |    0
drivers/net/{ => ethernet/isa}/eexpress.c          |    0
drivers/net/{ => ethernet/sun}/sun3_82586.c        |    0
drivers/net/{ => ethernet/isa}/seeq8005.c          |    0
drivers/net/{ => ethernet/sgi}/sgiseeq.c           |    0

	Arnd
