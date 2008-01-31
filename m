From: Frans Pop <elendil@planet.nl>
Subject: Re: Mostly revert "e1000/e1000e: Move PCI-Express device IDs over       to e1000e"
Date: Thu, 31 Jan 2008 02:26:01 +0100
Message-ID: <E1JKOBl-0007ne-EE@faramir.fjphome.nl>
References: <200801292359.m0TNxb75011826@hera.kernel.org> <20080129212314.91b9bb5b.randy.dunlap@oracle.com> <alpine.LFD.1.00.0801301631400.3426@www.l.google.com> <20080130235836.GV29368@does.not.exist>
Cc: akpm@linux-foundation.org, auke-jan.h.kok@intel.com,
	davem@davemloft.net, jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, randy.dunlap@oracle.com,
	torvalds@linux-foundation.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpsmtp-eml17.kpnxchange.com ([213.75.38.117]:3282 "EHLO
	hpsmtp-eml17.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758902AbYAaB0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 20:26:04 -0500
In-reply-To: <20080130235836.GV29368@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
>> Jeff, Auke, would something like this be acceptable? It makes it very
>> obvious in the driver table which entries are for the PCIE versions that
>> would be handled by the E1000E driver if it is enabled..
> 
> I don't like it:
> We should aim at having exactly one driver for one card.

There is one thing I don't understand, but that may well be just me...

>From Linus' original patch:
> +++ b/drivers/net/e1000/e1000_main.c
> +     INTEL_E1000_ETHERNET_DEVICE(0x108C),

So, apparently support for 8086:108c was removed from the e1000 driver.

>From my lspci:
$ lspci -nn | grep Ether
01:00.0 Ethernet controller [0200]: Intel Corporation 82573E Gigabit Ethernet Controller (Copper) [8086:108c] (rev 03)

But when I look at where that card is sitting:
$ readlink pci/devices/0000\:01\:00.0/driver
../../../../bus/pci/drivers/e1000

So, it's on the PCI bus, not on the PCI-Express bus (which I also have, but
which has no devices on it).

Or does the e1000e driver also support cards on the PCI bus?

If that's the case then the original changelog entry "Move PCI-Express
device IDs over to e1000e" is misleading as it's not only PCI-Express
devices...

Hmmm. Or does which driver is loaded decide on which bus the device ends up?

Confused,
FJP
