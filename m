From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: Re: [PATCH] net: phy: micrel: remove suspend/resume
Date: Fri, 26 Aug 2016 08:06:41 +0200
Message-ID: <b80f1ec4-ba5f-0d7e-60c7-25da42254d2f@c-s.fr>
References: <20160823111344.25FF41A2459@localhost.localdomain>
 <2ee9441d-1b3b-de6d-691d-b615c04c69d0@gmail.com>
 <8b2ab09d-761f-080b-8264-4464f9afc442@c-s.fr>
 <908c1da1-06a8-d92c-5ba0-874c8420268a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        xander.huff@ni.com, brad.mouring@ni.com, nathan.sullivan@ni.com
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegase1.c-s.fr ([93.17.236.30]:52470 "EHLO pegase1.c-s.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750712AbcHZGWA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 02:22:00 -0400
In-Reply-To: <908c1da1-06a8-d92c-5ba0-874c8420268a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Le 26/08/2016 à 06:35, Florian Fainelli a écrit :
> Le 24/08/2016 à 07:14, Christophe Leroy a écrit :
>>
>>
>> Le 23/08/2016 à 21:03, Florian Fainelli a écrit :
>>> +others,
>>>
>>> On 08/23/2016 04:13 AM, Christophe Leroy wrote:
>>>> In ERRATA DS80000700A dated 05 May 2016, Microship recommends to
>>>> not use software power down mode on KSZ8041 family.
>>>
>>> s/Microship/Microchip/
>>>
>>>> They say they have no plan to fix this ERRATA in future releases.
>>>
>>> The errata applies to specific revisions, is this revision present in
>>> the lower 4 bits of the MII_PHYSID2 register such that it could be used
>>> to key the disabling of the power down?
>>
>> It doesn't seem clear to me how this could/should be handled.
>>
>> According to the documentation, all variants have the same ID 0x0022151x
>> with revision x. A3 has ID 0x00221512 and A4 has 0x00221513.
>> According to the doc, the KSZ8041RNLI should has same ID. But according
>> to micrel driver, it has ID 0x00221537. And the buggy revision of that
>> one is rev A. Is it what the 7 means ?
>
> Humm the revision is typically stored on 4 bits, so 0x7 could mean
> anything here, it really depends if how they are allocating their revision.
>
> 0b0000 -> A0
> 0b0001 -> A1
> ...
> 0b0110 -> A6
> 0b0111 -> A7?
>
> Who knows.
>
>>
>> The ERRATA applies to KSZ8041NL revision A4 and to KSZ8041NL-AM revision
>> A3. My understanding it that both variants have ID 0x0022151x, ie
>> KSZ8041NL-AM revision A3 has ID 0x00221512 and KSZ8041NL revision A4 has
>> ID 0x00221513. But KSZ8041NL revision A3 also has ID 0x00221512 and the
>> ERRATA doesn't apply to it.
>>
>> So what can be done really ? Only apply the fix to ID 0x00221513 (which
>> is what I need as I have KSZ8041NL revision A4 on my boards) ? Or apply
>> it for all KSZ8041 and KSZ8041RNLI to be on the safe side ?
>
> I would apply it to just the KSZ8041NL rev. A4 for now, ideally we would
> want to track down the users of the KSZ8041RNLI and see if somebody
> could test that, realistically, we won't be able to, so I would err on
> the side of caution at the expense of slightly increased power
> consumption for that particular PHY and have a broader match of all the
> KSZ8041RNLI potentially affected.
>
> Does that make sense?
>

What about the KSZ8041NL-AM revision A3, which has the same PHY ID as 
the KSZ8041NL revision A3 ?
Shouldn't we also have a broader match on this one in order to cover all 
cases and also be on the side of caution ?

Christophe
