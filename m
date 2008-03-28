From: Harald Hannelius <harald@iki.fi>
Subject: Re: tg3 bad performance, lots of hardware interrupts
Date: Fri, 28 Mar 2008 19:37:29 +0200 (EET)
Message-ID: <alpine.DEB.1.00.0803281931060.5286@penti.org>
References: <alpine.DEB.1.00.0803271532570.30549@penti.org> <20080327.144925.196529669.davem@davemloft.net> <1206666100.5368.6.camel@dell> <alpine.DEB.1.00.0803281440460.23558@penti.org> <1206726560.6866.5.camel@dell>
 <Pine.LNX.4.64.0803281811420.32241@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from penti.org ([193.167.33.200]:54122 "EHLO penti.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752337AbYC1Rhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 13:37:38 -0400
In-Reply-To: <Pine.LNX.4.64.0803281811420.32241@twin.jikos.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 28 Mar 2008, Jiri Kosina wrote:
> On Fri, 28 Mar 2008, Michael Chan wrote:

>>> Phew, I thought that running ethtool -t was like doing stop-A-sync on
>>> a Sun. It took almost half an hour to run that ethtool -t command;
>> Something is very wrong.  ethtool -t should only take a few seconds to
>> complete.  You can try ethtool -t eth0 online to reduce the number of
>> tests to see if it makes a difference.
>> How many of these NICs do you have?  If you have more than one, do they
>> all behave the same way?  Have they ever worked well before?
>
> Harald, is the IRQ of eth0 shared with any other device? (cat
> /proc/interrupts will show).

# cat /proc/interrupts
            CPU0       CPU1
   0:        111          1   IO-APIC-edge      timer
   1:          0          2   IO-APIC-edge      i8042
   2:          0          0    XT-PIC-XT        cascade
   5:          0          0   IO-APIC-fasteoi   sata_nv
   7:        856         51   IO-APIC-fasteoi   ohci_hcd:usb2
  10:          0          3   IO-APIC-fasteoi   sata_nv, ehci_hcd:usb1
  11:       4305          7   IO-APIC-fasteoi   sata_nv
  12:          0          4   IO-APIC-edge      i8042
216:       4217     128932   PCI-MSI-edge      eth2
217:     161107     685351   PCI-MSI-edge      eth0
NMI:          0          0   Non-maskable interrupts
LOC:    2380762    2619917   Local timer interrupts
RES:       3000       3269   Rescheduling interrupts
CAL:         16         31   function call interrupts
TLB:         64        111   TLB shootdowns
TRM:          0          0   Thermal event interrupts
SPU:          0          0   Spurious interrupts
ERR:          1
MIS:          0

Well, shared or not, yes and no. I think that /proc/interrupts contains 
soft-interrupts. The problem child is interface eth2.

As rapported by ifconfig the interface is on IRQ 5:

# ifconfig eth2
eth2      Link encap:Ethernet  HWaddr 00:10:18:30:E6:D6
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:196898 errors:0 dropped:0 overruns:0 frame:0
           TX packets:19 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:69887991 (66.6 MiB)  TX bytes:1216 (1.1 KiB)
           Interrupt:5

That'd be the same as sata_nv.

# ifconfig eth2
eth2      Link encap:Ethernet  HWaddr 00:10:18:30:E6:D6
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:196898 errors:0 dropped:0 overruns:0 frame:0
           TX packets:19 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:69887991 (66.6 MiB)  TX bytes:1216 (1.1 KiB)
           Interrupt:5

I changed the settings "PnP OS" in the BIOS (acpi on/off?) and tried 
booting with both pci=routeirq (or smth like that, see original post) on 
and off to no avail.

I'm stumped. I have never experienced anything quite like this before. 
Usually an IRQ-conflict has crashed my computers, not just slowed them 
down (or maybe these dual-core opterons are just that incredibly fast 
nowadays that the do nothing incredibly fast :) ). Then again, I haven't 
had an IRQ-conflict on my boxen in years.

Buggy motherboard? Buggy NIC? The motherboard has the latest available 
BIOS as per supermicro's webpage.

I'm getting three PCIe e1000's next week, I'll try with these instead.


-- 
A: Top Posters!                                      |  s/y Charlotta |
Q: What is the most annoying thing on mailing lists? |    FIN-2674    |
   http://www.fe83.org/ Finn Express Purjehtijat ry   |  ============= |
Harald H Hannelius | harald (At) iki (dot) fi | GSM +358 50 594 1020
