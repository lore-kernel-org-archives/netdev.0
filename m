From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Fri, 04 Nov 2016 16:55:18 +0000
Message-ID: <yw1xwpgji3rd.fsf@unicorn.mansr.com>
References: <581767BF.4020308@free.fr> <20161031155334.GF9441@lunn.ch>
        <58177128.8090403@free.fr> <581C8691.2060306@free.fr>
        <yw1xy40zjrcw.fsf@unicorn.mansr.com> <581C9273.906@free.fr>
        <20161104135752.GC3600@lunn.ch> <yw1xtwbnjq88.fsf@unicorn.mansr.com>
        <20161104142223.GD3600@lunn.ch> <yw1xpombjnfn.fsf@unicorn.mansr.com>
        <20161104151744.GG3600@lunn.ch> <yw1xh97njmmw.fsf@unicorn.mansr.com>
        <7b10d4f3-68be-f5d7-633b-21854532ac26@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew@lunn.ch>, Mason <slash.tmp@free.fr>,
        netdev <netdev@vger.kernel.org>,
        Timur Tabi <timur@codeaurora.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Daniel Mack <zonque@gmail.com>,
        Sebastian Frias <sf84@laposte.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:43814 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964922AbcKDQzV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 12:55:21 -0400
In-Reply-To: <7b10d4f3-68be-f5d7-633b-21854532ac26@gmail.com> (Florian
        Fainelli's message of "Fri, 4 Nov 2016 09:45:41 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 11/04/2016 08:22 AM, Måns Rullgård wrote:
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>>> On Fri, Nov 04, 2016 at 03:05:00PM +0000, Måns Rullgård wrote:
>>>> Andrew Lunn <andrew@lunn.ch> writes:
>>>>
>>>>>>> I agree with you. But fixing it is likely to break boards which
>>>>>>> currently have "rgmii", but actually need the delay in order to work.
>>>>>>
>>>>>> Does the internal delay here refer to the PHY or the MAC?  It's a
>>>>>> property of the MAC node after all.
>>>>>
>>>>> It is the PHY which applies the delay.
>>>>
>>>> Says who?
>>>
>>> The source code.
>> 
>> There's source code that disagrees with that.  The Broadcom GENET
>> driver, for instance.
>
> Correct, and in the case where the MAC adds the delay while transmitting
> (because it supports that) the expectation is that the PHY would remove
> such a delay internally, conversely, the PHY would introduce a delay
> while transmitting back to the PHY, in order to produce the desired 90
> degrees shift on the RGMII signals, and get reproduce the correct clock
> and data alignment internally.
>
>> 
>>>>  Some MACs can do it too.
>>>
>>> I'm sure they can. But look at the code. Nearly none do, and those
>>> that do are potentially broken.
>> 
>> Those few drivers that do anything differently based on these values
>> enable clock delay in the MAC.  That's why I wrote the NB8800 driver the
>> way I did.
>> 
>
> I don't really what is wrong with the nb8800 driver at the moment, so
> maybe this is just a configuration issue with the Atheros PHY driver,
> it's not like it has not given people headache judging by the recent
> discussions...

We don't even know if the problems Mason is having are caused by
incorrect clock skew in the first place.  I'd suggest not patching
anything at all until he gets it working.

-- 
Måns Rullgård
