From: Tuomas Jormola <tj@solitudo.net>
Subject: Re: PROBLEM: A set of networking related oopses
Date: Sat, 8 Mar 2008 18:13:55 +0200
Message-ID: <0CFB0535-DE03-4C13-8EC5-9471CED9B6BE@solitudo.net>
References: <D04F01C2-03F0-4FBC-933D-62899456BEE9@solitudo.net> <47D26201.2060201@gmail.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh05.mail.saunalahti.fi ([62.142.5.111]:45066 "EHLO
	emh05.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351AbYCHQN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 11:13:59 -0500
In-Reply-To: <47D26201.2060201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 8 Mar 2008, at 11:53, Jarek Poplawski wrote:

> Tuomas Jormola wrote, On 03/06/2008 08:05 PM:
>
>> Hello,
>
> Hi,
>
>> [1.] One line summary of the problem:
>> My gateway machine is suffering from kernel oopses that don't kill  
>> the
>> machine, but do occur every now and then
>
> Do you have irq balancing enabled for your eths (are eth interrupts  
> shown
> for more than one cpu in /proc/interrupts)? If so, try to disable  
> this.
>
> This link could be helpful:
>
> http://marc.info/?l=linux-netdev&m=120349568512423&w=2
Thanks for the tip. Currently, I have

(18:08:32)(tj@shakti)(~)$ cat /proc/interrupts
            CPU0       CPU1
   0:        334        190   IO-APIC-edge      timer
   1:          5          6   IO-APIC-edge      i8042
   8:          3          4   IO-APIC-edge      rtc
   9:          0          0   IO-APIC-fasteoi   acpi
  12:          3          1   IO-APIC-edge      i8042
  16:        223        207   IO-APIC-fasteoi   uhci_hcd:usb3,  
ehci_hcd:usb7, libata
  18:     875645     873991   IO-APIC-fasteoi   uhci_hcd:usb1,  
uhci_hcd:usb6, eth0
  19:          2          1   IO-APIC-fasteoi   uhci_hcd:usb5, ohci1394
  20:          0          0   IO-APIC-fasteoi   uhci_hcd:usb2
  21:          0          0   IO-APIC-fasteoi   uhci_hcd:usb4,  
ehci_hcd:usb8
  22:          4          3   IO-APIC-fasteoi   heci
217:     498561     498427   PCI-MSI-edge      eth1
218:   88587922   88715380   PCI-MSI-edge      ahci
NMI:          0          0   Non-maskable interrupts
LOC:   12081665   11441729   Local timer interrupts
RES:    1372553    1227633   Rescheduling interrupts
CAL:     513863     442462   function call interrupts
TLB:      44149      48844   TLB shootdowns
TRM:          0          0   Thermal event interrupts
SPU:          0          0   Spurious interrupts
ERR:          0
MIS:          0

So I would be able to bind eth0 to CPU0 by running

echo 1 > /proc/irq/18/smp_affinity

right? http://www.cs.uwaterloo.ca/~brecht/servers/apic/SMP- 
affinity.txt says that smp affinity only works for drivers that  
support IO-APIC. The eth1 card is an old Intel card, and looks like it  
doesn't support this. I guess I'll replace the card with a newer one.

-- 
Tuomas Jormola <tj@solitudo.net>
