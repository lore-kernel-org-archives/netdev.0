From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [PATCH 2/3] enic: add main netdev file withmoduleinfrastructure
Date: Wed, 17 Sep 2008 12:17:08 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809171216070.4712@palito_client100.nuovasystems.com>
References: <1221678230.3244.101.camel@achroite>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Scott Feldman <scofeldm@cisco.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:54013 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752726AbYIQTRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 15:17:24 -0400
In-Reply-To: <1221678230.3244.101.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Sep 2008, Ben Hutchings wrote:

> On Wed, 2008-09-17 at 11:51 -0700, Scott Feldman wrote:
>> On Wed, 17 Sep 2008, Ben Hutchings wrote:
>>
>>> On Tue, 2008-09-16 at 18:49 -0700, Scott Feldman wrote:
>>>>>> +static void enic_notify_timer(unsigned long data)
>>>>>> +{
>>>>>> +	struct enic *enic = (struct enic *)data;
>>>>>> +
>>>>>> +	enic_notify_check(enic);
>>>>>> +
>>>>>> +	mod_timer(&enic->notify_timer, round_jiffies(ENIC_NOTIFY_TIMER_PERIOD));
>>>>>
>>>>> You want round_jiffies_relative() not round_jiffies().
>>>>
>>>> No, I want round_jiffies().
>>> [...]
>>>
>>> The kernel-doc says:
>>> "round_jiffies() rounds an absolute time in the future (in jiffies)
>>> up or down to (approximately) full seconds. This is useful for timers
>>> for which the exact time they fire does not matter too much, as long as
>>> they fire approximately every X seconds."
>>>
>>> You're passing in ENIC_NOTIFY_TIMER_PERIOD which is a relative time.
>>
>> I tried both and round_jiffies(2) gave the desired result of calling the timer
>> every two seconds.  Using round_jiffies_relative(2) called the timer
>> continuously.
>
> Sorry, yes, round_jiffies_relative() not only takes but also returns a
> relative time - which if interpreted as absolute is always in the past.
> So calling round_jiffies() is right, but the argument should be jiffies
> + ENIC_NOTIFY_TIMER_PERIOD.

Indeed, I'll make that change to add in jiffies.

-scott
