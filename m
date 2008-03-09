From: Tuomas Jormola <tj@solitudo.net>
Subject: Re: PROBLEM: A set of networking related oopses
Date: Sun, 9 Mar 2008 18:58:47 +0200
Message-ID: <2DAAA71E-5F03-41CA-B7E0-5BE4073D14F5@solitudo.net>
References: <D04F01C2-03F0-4FBC-933D-62899456BEE9@solitudo.net> <47D26201.2060201@gmail.com> <0CFB0535-DE03-4C13-8EC5-9471CED9B6BE@solitudo.net> <20080308175721.GA3582@ami.dom.local>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh01.mail.saunalahti.fi ([62.142.5.107]:60683 "EHLO
	emh01.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbYCIQ6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 12:58:52 -0400
In-Reply-To: <20080308175721.GA3582@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 8 Mar 2008, at 19:57, Jarek Poplawski wrote:

> On Sat, Mar 08, 2008 at 06:13:55PM +0200, Tuomas Jormola wrote:
> ...
>> (18:08:32)(tj@shakti)(~)$ cat /proc/interrupts
>>           CPU0       CPU1
> ...
>> 18:     875645     873991   IO-APIC-fasteoi   uhci_hcd:usb1,
>> uhci_hcd:usb6, eth0
>> 19:          2          1   IO-APIC-fasteoi   uhci_hcd:usb5, ohci1394
>> 20:          0          0   IO-APIC-fasteoi   uhci_hcd:usb2
>> 21:          0          0   IO-APIC-fasteoi   uhci_hcd:usb4,
>> ehci_hcd:usb8
>> 22:          4          3   IO-APIC-fasteoi   heci
>> 217:     498561     498427   PCI-MSI-edge      eth1
>> 218:   88587922   88715380   PCI-MSI-edge      ahci
> ...
>> So I would be able to bind eth0 to CPU0 by running
>>
>> echo 1 > /proc/irq/18/smp_affinity
>>
>> right? http://www.cs.uwaterloo.ca/~brecht/servers/apic/SMP-affinity.txt
>> says that smp affinity only works for drivers that support IO-APIC.  
>> The
>> eth1 card is an old Intel card, and looks like it doesn't support  
>> this. I
>> guess I'll replace the card with a newer one.
>
> Should be right. If it's possibile, you can try if moving eth0 to
> another slot could give it it's own irq.

> I think it should work with both of your cards: eth1 uses newer type
> of interrupts - are you sure it's e100?
No, eth0 is the one driven by e100 driver. The card itself is probably  
ten years old. So it's old but it has always been a reliable work  
horse for me :) eth1 is embedded on the Intel motherboard. It's brand  
new and it's driven by e1000e driver. I'm not sure which interface's  
interrupts are giving these oopses. The machine was booted two days  
ago, and after that, still no oopses, though net traffic has been  
quite light. Should there be new oopses, I will replace the old card  
with a newer Intel gigabit card that I have laying around, and put it  
in a different PCI slot.

>
>
> You can also check if it really fixes the problem by booting with
> a kernel parameter: noirqbalance.
Ok, thanks for the info. I'll try that if changing the card doesn't  
help.

-- 
Tuomas Jormola <tj@solitudo.net>



