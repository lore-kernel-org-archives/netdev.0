From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Simple question about network stack
Date: Tue, 25 Dec 2007 11:52:48 +0300
Message-ID: <4770C4E0.1040708@bigtelecom.ru>
References: <476F8166.4070801@bigtelecom.ru> <20071224205358.5c192f8d@catlap>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Marek Kierdelewicz <marek@piasta.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:40892 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbXLYIw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 03:52:57 -0500
In-Reply-To: <20071224205358.5c192f8d@catlap>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marek Kierdelewicz:
> Hi,
>
>   
>> Have 2 Ethernet adapters e1000. Have 8 CPU (4 real).
>> Computer work as Shaper. Use only TC rules to shape and IPTABLES to
>> drop.
>> question:
>> 1. I may balance load to other cpu? I understand that i can't balance
>> polling place, but find in TC and IPTABLES hash may do different cpu?
>>     
>
> You need as many nics as cpus to effectivelu use all your processing
> power. You can pair-up nics and cpus by configuring appropriate irq
> smp affinity. Read in [1] from line 350 on.
>   
Interesting. Sorry if my questions will be stupid. "smp affinity" its
was i need, but it not work for me, and never work if i remember =(
Maybe Guru of Network ask me where i have simple stupid mistake?

In theory
#cat ffffffff > /proc/irq/ID/smp_affinity
set mask that all cpus must get interrupts RR

but i see in cat /proc/interrupts that all interrupts get only CPU0
On CPU1 0 interrupts

i do
#cat 2 > /proc/irq/16/smp_affinity
#cat 2 > /proc/irq/17/smp_affinity
#echo /proc/irq/1[67]/smp_affinity
00000002
00000002

Great. Interrupts go to CPU1

#cat 1 > /proc/irq/16/smp_affinity
#cat 1 > /proc/irq/17/smp_affinity
#echo /proc/irq/1[67]/smp_affinity
00000001
00000001

Great. Interrupts go to CPU0

#cat 3 > /proc/irq/16/smp_affinity
#cat 3 > /proc/irq/17/smp_affinity
#echo /proc/irq/1[67]/smp_affinity
00000003
00000003

Strange. Interrupts go to CPU0 only.

Where i have mistake? Why i not have RR? Or i mistake in SMP Affinity idea?
Thanks for answers!

Slavon


> Another option is to use recent e1000 nics with multiqueue capability.
> Read in [2]. Google for more information. I'm not sure but you'll
> probably need non-kerel recent e1000 drivers from sourceforge.
>
> [1]http://www.mjmwired.net/kernel/Documentation/filesystems/proc.txt
> [2]http://www.mjmwired.net/kernel/Documentation/networking/multiqueue.txt
>
> cheers,
> Marek Kierdelewicz
>
>   

