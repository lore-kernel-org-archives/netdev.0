From: James Kosin <jkosin@intcomgrp.com>
Subject: Re: EG20T and Micrel KSZ9021 Gigabit Ethernet
Date: Thu, 25 Oct 2012 16:52:26 -0400
Message-ID: <5089A68A.5000206@intcomgrp.com>
References: <506F30A2.500@intcomgrp.com> <20121005195343.GA7083@electric-eye.fr.zoreil.com> <506F41FC.7080108@intcomgrp.com> <20121005210910.GA10931@electric-eye.fr.zoreil.com> <507D95A2.9090206@intcomgrp.com> <5089A17C.3000108@intcomgrp.com> <CAE3RKNmEWk+=OOWzpA+wEmSGRdbKeCpn6PS+dNTTridAPEXbuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>
To: Veaceslav Falico <darkmag@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server104.appriver.com ([207.97.242.188]:2543 "EHLO
	server104.appriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935908Ab2JYUw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 16:52:29 -0400
In-Reply-To: <CAE3RKNmEWk+=OOWzpA+wEmSGRdbKeCpn6PS+dNTTridAPEXbuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/25/2012 4:49 PM, Veaceslav Falico wrote:
> On Thu, Oct 25, 2012 at 10:30 PM, James Kosin <jkosin@intcomgrp.com> wrote:
>> On 10/16/2012 1:13 PM, James Kosin wrote:
>>> Hmmm... interesting turn of events.
>>>
>>> The problem seems to be in 10 speed support.  I hooked the Ethernet
>>> PHY to a100TX port and don't get these errors.
>>>
>>> James
>>>
>>> On 10/5/2012 5:09 PM, Francois Romieu wrote:
>>>> (please don't top post)
>>>>
>>>> James Kosin <jkosin@intcomgrp.com> :
>>>>> The driver is always reporting:
>>>>>     [...] pch_gbe: Transfer Carrier Sense Error
>>>> You should send more information. Say dmesg, link stats (ip link),
>>>> ethtool information, stats and offload settings.
>>>>
>>>> We have a small Micrel ksz9021 phy driver that the pch_gbe driver does
>>>> not use and the latter pokes into some phy specific register (0x10) that
>>>> the Micrel document does not include in its list of vendor registers...
>>>>
>>>> Does your motherboard vendor offer some linux driver ?
>>>>
>>>> /note to myself: pch_gbe should use standard mii.h registers instead
>>>> of defining its own redundant set of registers.
>>>>
>>>> --
>>>> Ueimor
>>>>
>> Ueimor & All,
>>
>> The "Transfer Carrier Sense Error" seems to have been hardware related.
>> I replaced with a 10/100Mbps device and the interface is working
>> correctly now.  My hardware engineer is going to look at the 10Mbps HUB
>> later to find out what is going on with that piece of equipment; so, we
>> know what to do when we have future issues.
> Did you run pch_gbe on 1gbps? It might be also speed related, in my tests
> the driver gave CRC errors only on high loads.
>
>> James
I'm not planning on using 1Gbps ... we plan on limiting this by only
advertising and attaching the connections needed for 10/100Mbps support.
