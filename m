From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: VLAN filtering/VLAN aware bridge problems
Date: Tue, 12 Nov 2013 22:31:45 +0100
Message-ID: <52829E41.6060604@profihost.ag>
References: <521F4393.1020907@profihost.ag> <521FB2E3.6060508@redhat.com> <522048CB.1090000@profihost.ag> <5220A895.5040501@redhat.com> <2036307B-46CC-40F6-ACE0-93A08BDEE0B9@profihost.ag> <522F2887.1080300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:42557 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756660Ab3KLVi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 16:38:27 -0500
In-Reply-To: <522F2887.1080300@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry for the very late response.

Am 10.09.2013 16:11, schrieb Vlad Yasevich:
> On 08/30/2013 11:01 AM, Stefan Priebe - Profihost AG wrote:
>> Yes
>>
>
> Can you apply this patch and see if this fixes your problem.
>      http://patchwork.ozlabs.org/patch/273841/
>
> In my attempts to reproduce your problem I didn't configuring filtering
> on the upper bridge, but that is what could have been causing
> your problem.  I'll attempt it and let you know.

Even with the complete patchset which was merged upstream it doesn't 
work ;-(

What's wrong there and / or how can i debug?

Stefan

> -vlad
>
>
>> Stefan
>>
>> This mail was sent with my iPhone.
>>
>> Am 30.08.2013 um 16:13 schrieb Vlad Yasevich <vyasevic@redhat.com>:
>>
>>> On 08/30/2013 03:24 AM, Stefan Priebe - Profihost AG wrote:
>>>> Am 29.08.2013 22:45, schrieb Vlad Yasevich:
>>>>> On 08/29/2013 08:50 AM, Stefan Priebe - Profihost AG wrote:
>>>>
>>>>>> The packets never reach the TAP device.
>>>>>>
>>>>>> Here is an output of ip a l (vlan 3021):
>>>>>
>>>>> Can you provide output of brctl show?
>>>>
>>>> Sure:
>>>> # brctl show
>>>> bridge name     bridge id               STP enabled     interfaces
>>>> vmbr0           8000.00259084dea8       no              bond0
>>>>                                                          tap320i0
>>>> vmbr1           8000.00259084deaa       no              bond1
>>>> vmbr1v3021              8000.00259084deaa       no
>>>> tap320i1
>>>>                                                          vmbr1.3021
>>>
>>> so let me see if I can understand this configuration.
>>>
>>>           vmbr1v3021 (bridge)
>>>            /          \
>>>        tap320i1       vmbr1.3021 (vlan)
>>>                           \
>>>                           vmbr1 (bridge)
>>>                              \
>>>                             bond1
>>>                                \
>>>                              eth X
>>>
>>>
>>> Is that right? Is this the setup that has the problem you are
>>> describing?
>>>
>>> Thanks
>>> -vlad
>>>
>>>>> On the off chance that you are actually trying to configure vlan
>>>>> filtering, can you give this patch a try (net-2.6 tree):
>>>>>
>>>>> Author: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>>>> Date:   Tue Aug 20 17:10:18 2013 +0900
>>>>>
>>>>>      bridge: Use the correct bit length for bitmap functions in the
>>>>> VLAN
>>>>> code
>>>>>
>>>>> I don't think it made it to stable yet.
>>>>
>>>> I addd that patch and now the vlan stuff works at least on the host
>>>> node. But my tap devices still don't work.
>>>>
>>>> I also tried to attach the tap device on top of a vlan attached to
>>>> bond1
>>>> but then gvrp does not work anymore. The kernel announces gvrp once and
>>>> then does not answer the query packets from the switch.
>>>>
>>>> Stefan
>>>
>
