From: Harald Hannelius <harald@iki.fi>
Subject: Re: tg3 bad performance, lots of hardware interrupts
Date: Fri, 28 Mar 2008 20:09:17 +0200 (EET)
Message-ID: <alpine.DEB.1.00.0803282006530.7191@penti.org>
References: <alpine.DEB.1.00.0803271532570.30549@penti.org> <20080327.144925.196529669.davem@davemloft.net> <1206666100.5368.6.camel@dell> <alpine.DEB.1.00.0803281440460.23558@penti.org> <1206726560.6866.5.camel@dell> <Pine.LNX.4.64.0803281811420.32241@twin.jikos.cz>
 <alpine.DEB.1.00.0803281931060.5286@penti.org> <1206731211.6866.13.camel@dell>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jiri Kosina <jkosina@suse.cz>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from penti.org ([193.167.33.200]:53577 "EHLO penti.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755052AbYC1SJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 14:09:27 -0400
In-Reply-To: <1206731211.6866.13.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 28 Mar 2008, Michael Chan wrote:

> On Fri, 2008-03-28 at 19:37 +0200, Harald Hannelius wrote:
>> # cat /proc/interrupts
>>             CPU0       CPU1
>>    0:        111          1   IO-APIC-edge      timer
>>    1:          0          2   IO-APIC-edge      i8042
>>    2:          0          0    XT-PIC-XT        cascade
>>    5:          0          0   IO-APIC-fasteoi   sata_nv
>>    7:        856         51   IO-APIC-fasteoi   ohci_hcd:usb2
>>   10:          0          3   IO-APIC-fasteoi   sata_nv, ehci_hcd:usb1
>>   11:       4305          7   IO-APIC-fasteoi   sata_nv
>>   12:          0          4   IO-APIC-edge      i8042
>> 216:       4217     128932   PCI-MSI-edge      eth2
>> 217:     161107     685351   PCI-MSI-edge      eth0
>> NMI:          0          0   Non-maskable interrupts
>> LOC:    2380762    2619917   Local timer interrupts
>> RES:       3000       3269   Rescheduling interrupts
>> CAL:         16         31   function call interrupts
>> TLB:         64        111   TLB shootdowns
>> TRM:          0          0   Thermal event interrupts
>> SPU:          0          0   Spurious interrupts
>> ERR:          1
>> MIS:          0
>>
>> Well, shared or not, yes and no. I think that /proc/interrupts
>> contains
>> soft-interrupts. The problem child is interface eth2.
>>
>> As rapported by ifconfig the interface is on IRQ 5:
>
> eth2 is using MSI.  When using MSI, the IRQ reported by ifconfig is not
> accurate.  You said you have tried booting with nomsi, but have you
> confirmed that by checking /proc/interrupts?

I did, at least the interface wasn't on MSI-edge anymore. I cannot 
remember what IRQ the NIC took when booted with pci=nomsi (something like 
that), it could have been 10 or other IRQ below 20, if I recall correctly.


-- 
A: Top Posters!                                      |  s/y Charlotta |
Q: What is the most annoying thing on mailing lists? |    FIN-2674    |
   http://www.fe83.org/ Finn Express Purjehtijat ry   |  ============= |
Harald H Hannelius | harald (At) iki (dot) fi | GSM +358 50 594 1020
