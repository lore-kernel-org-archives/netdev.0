From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/12] bnxt_en: Add XDP support.
Date: Fri, 03 Feb 2017 17:29:18 -0500 (EST)
Message-ID: <20170203.172918.2084277179948808335.davem@davemloft.net>
References: <CALx6S35rQa25soEiidnK12pbBPGcuhsE_Nr-epYNL-P+srwSOg@mail.gmail.com>
        <20170203.170240.2175427621637065084.davem@davemloft.net>
        <CALx6S36Gp_dk218X0zAUQzDNxhst+CnZFs7Y5zN4-mi5HWWKew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.chan@broadcom.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57430 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbdBCW3T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:29:19 -0500
In-Reply-To: <CALx6S36Gp_dk218X0zAUQzDNxhst+CnZFs7Y5zN4-mi5HWWKew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 3 Feb 2017 14:25:00 -0800

> On Fri, Feb 3, 2017 at 2:02 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Fri, 3 Feb 2017 13:58:56 -0800
>>
>>> On Fri, Feb 3, 2017 at 1:50 PM, David Miller <davem@davemloft.net> wrote:
>>>> From: Michael Chan <michael.chan@broadcom.com>
>>>> Date: Fri, 3 Feb 2017 13:13:47 -0800
>>>>
>>>>> On Fri, Feb 3, 2017 at 12:49 PM, David Miller <davem@davemloft.net> wrote:
>>>>>>
>>>>>> Please _DO NOT_ guard XDP support with an ifdef the user
>>>>>> can modify.
>>>>>>
>>>>>> Treat it like any other common netdev feature a driver might
>>>>>> support such as checksum offloading or GRO.
>>>>>>
>>>>>
>>>>> David, I want to make sure I understand completely.  Are you saying
>>>>> don't use Kconfig option for XDP?  Have it always available?
>>>>
>>>> Yes.
>>>>
>>>> I don't see a similar config option used in any other driver.
>>>>
>>>> What's really driving me completely mad about driver XDP adoption
>>>> is that there is so much inconsistency.
>>>>
>>>> If you do not see another XDP supporting driver do something, don't be
>>>> tempted to blaze your own trail and handle something in a unique way.
>>>>
>>>> We don't set precedence by one driver saying "hey it's better to do
>>>> things this way, forget what all the other drivers are doing."  Rather
>>>> we have a "discussion" about what the appropriate thing is to do and
>>>> convert all the drivers only after a decision has been made.
>>>>
>>>> Meanwhile we keep the status quo.
>>>
>>> I am working on some API changes that will hopefully get a little
>>> consistency across these drivers (this includes feature flag
>>> NETIF_F_XDP). This will reduce code some and should be good cleanup,
>>> but XDP is currently very intertwined with the critical data path so
>>> we might need to be looking at this for a while. There's now more
>>> drivers with XDP support than when I started this work, so I don't
>>> think bnxt should wait for this cleanup-- it's just one more driver
>>> we'll have to retrofit.
>>
>> Of course.
>>
>> Michael just respin with the Kconfig change and I'll apply your
>> series.  In fact I was about to until I noticed the XDP Kconfig knob
>> :)
> 
> Meaning no Kconfig and no features flag I assume...

For now, yes.
