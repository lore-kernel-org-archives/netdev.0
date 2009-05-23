From: Michael Riepe <michael.riepe@googlemail.com>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sat, 23 May 2009 18:53:28 +0200
Message-ID: <4A182A08.9050305@googlemail.com>
References: <200903041828.49972.m.bueker@berlin.de>	 <4A0C7443.1010000@googlemail.com>	 <1243042174.3580.23.camel@obelisk.thedillows.org>	 <200905231124.28925.mb@bu3sch.de>  <4A1809B0.3030109@googlemail.com>	 <1243090308.4217.6.camel@obelisk.thedillows.org>	 <4A182066.9030201@googlemail.com> <1243097173.4217.7.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	=?ISO-8859-15?Q?Michael_B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:57883 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697AbZEWQxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 12:53:30 -0400
In-Reply-To: <1243097173.4217.7.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Dillow wrote:
> On Sat, 2009-05-23 at 18:12 +0200, Michael Riepe wrote:
> 
>>If I use two connections (iperf -P2) and nail iperf to both threads of a
>>single core with taskset (the program is multi-threaded, just in case
>>you wonder), I get this:
>>
>>CPU 0+2:  0.0-60.0 sec  4.65 GBytes    665 Mbits/sec
>>CPU 1+3:  0.0-60.0 sec  6.43 GBytes    920 Mbits/sec
>>
>>That's quite a difference, isn't it?
>>
>>Now I wonder what CPU 0 is doing...
> 
> 
> Where does /proc/interrupts say the irqs are going?

Oh well...

           CPU0       CPU1       CPU2       CPU3
  0:         66          0          0          0   IO-APIC-edge      timer
  1:          2          0          0          0   IO-APIC-edge      i8042
  7:          0          0          0          0   IO-APIC-edge
parport0
  8:          1          0          0          0   IO-APIC-edge      rtc0
  9:          0          0          0          0   IO-APIC-fasteoi   acpi
 12:          4          0          0          0   IO-APIC-edge      i8042
 14:          0          0          0          0   IO-APIC-edge
ata_piix
 15:          0          0          0          0   IO-APIC-edge
ata_piix
 16:          0          0          0          0   IO-APIC-fasteoi
uhci_hcd:usb4
 18:          0          0          0          0   IO-APIC-fasteoi
uhci_hcd:usb3
 19:       9696          0          0          0   IO-APIC-fasteoi
ata_piix, uhci_hcd:usb2
 22:        471          0          0          0   IO-APIC-fasteoi   HDA
Intel
 23:        100          0          0          0   IO-APIC-fasteoi
uhci_hcd:usb1, ehci_hcd:usb5
 27:   48463995          0          0          0   PCI-MSI-edge      eth0
NMI:          0          0          0          0   Non-maskable interrupts
LOC:     460965     294620     324902     358771   Local timer interrupts
RES:      30111     286150     113295     268387   Rescheduling interrupts
CAL:       1140       1143         52         34   Function call interrupts
TLB:       2223        952       1184       2573   TLB shootdowns
SPU:          0          0          0          0   Spurious interrupts
ERR:          0
MIS:          0


-- 
Michael "Tired" Riepe <michael.riepe@googlemail.com>
X-Tired: Each morning I get up I die a little
