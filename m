From: Christian Kujau <christian@g-house.de>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Fri, 6 Apr 2007 19:19:25 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0704061852270.3963@sheep.housecafe.de>
References: <20070403065810.GA1832@ff.dom.local>
 <Pine.LNX.4.64.0704031618070.3963@sheep.housecafe.de> <20070404112100.GA1979@ff.dom.local>
 <Pine.LNX.4.64.0704041412310.3963@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jarek Poplawski <jarkao2@o2.pl>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, malte@g-house.de,
	Francois Romieu <romieu@fr.zoreil.com>
To: Christian Kujau <christian@g-house.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.g-housing.de ([81.169.133.75]:37304 "EHLO mail.g-house.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993049AbXDFSTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 14:19:35 -0400
In-Reply-To: <Pine.LNX.4.64.0704041412310.3963@sheep.housecafe.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Apr 2007, Christian Kujau wrote:
>> Maybe it's a real locking problem. Here are some more
>> suggestions for testing (if you don't find anything better):
>> - try without SMP, so: 'acpi=off lapic nosmp'

We were able to have our hosting provider to replace the 8139too with a 
E100, the onboard r8169 stayed of course. After this, the box came back 
fine...only to lock up again shortly after :(

So again we spoke to our hosting provider and they just took out the 2 
SATA disks and put them in a completely new system: amd64 dualcore 
again, 2 GB ram, r8169 onboard NIC, e100 pci-slot NIC. Now booting 
2.6.20.4 and even 2.6.18-4-k7 (the debian kernel) with IOAPIC eabled 
seems to work, meaning the box is up since yesterday evening and 
interrupts are shared. Not equally, but still:

# cat /proc/interrupts
            CPU0       CPU1
   0:        111          0   IO-APIC-edge      timer
   1:          7          9   IO-APIC-edge      i8042
   4:        260          1   IO-APIC-edge      serial
   6:          0          3   IO-APIC-edge      floppy
   8:          0          1   IO-APIC-edge      rtc
   9:          0          0   IO-APIC-fasteoi   acpi
  16:        157     575579   IO-APIC-fasteoi   eth0
  17:    3812553          1   IO-APIC-fasteoi   eth1
  19:     100651    8262484   IO-APIC-fasteoi   libata
NMI:          0          0
LOC:   17272991   17266237
ERR:          0
MIS:          0

While this is a good thing, we now have different problems: our 2nd sata 
drive is not usable any more, but we again we doubt hardware problems, 
because this disk has been replaced already back in the old box...

but yes, this seem to be different problems, for the curious among 
you I've put details here: http://nerdbynature.de/bits/2.6.20.4/db2/

Thanks to all who have replied,
Christian.
-- 
BOFH excuse #209:

Only people with names beginning with 'A' are getting mail this week (a la Microsoft)
