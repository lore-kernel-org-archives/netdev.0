From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA
 drivers
Date: Fri, 05 Nov 2010 08:51:20 -0400
Message-ID: <4CD3FDC8.8060808@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>	<1288316896.1836.41.camel@Joe-Laptop>	<4CCB3BF1.7070000@windriver.com>	<1288390127.28828.225.camel@Joe-Laptop>	<1288396919.15283.23.camel@jtkirshe-MOBL1>	<4CD323AF.20609@windriver.com> <AANLkTim2yH7eAqqYQW+JVC5GtFR5mX4uZnMa02+yubFk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42010 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab0KEMvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 08:51:25 -0400
In-Reply-To: <AANLkTim2yH7eAqqYQW+JVC5GtFR5mX4uZnMa02+yubFk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-11-04 10:28 PM, Jeff Kirsher wrote:
> On Thu, Nov 4, 2010 at 14:20, Paul Gortmaker
> <paul.gortmaker@windriver.com>  wrote:
>> On 10-10-29 08:01 PM, Jeff Kirsher wrote:
>>> On Fri, 2010-10-29 at 15:08 -0700, Joe Perches wrote:
>>>> On Fri, 2010-10-29 at 17:26 -0400, Paul Gortmaker wrote:
>>>>> On 10-10-28 09:48 PM, Joe Perches wrote:
>>>>>> On Thu, 2010-10-28 at 21:19 -0400, Paul Gortmaker wrote:
>>>>>>> The drivers/net dir has a lot of files - originally there were
>>>>>>> no subdirs, but at least now subdirs are being used effectively.
>>>>>>> But the original drivers from 10+ years ago are still right
>>>>>>> there at the top.  This series creates a drivers/net/legacy dir.
>>>>>> I like this idea.
>>>>>> I suggest a bit of a further grouping by using a
>>>>>> drivers/net/ethernet directory and putting those
>>>>>> legacy drivers in a new subdirectory
>>>>>> drivers/net/ethernet/legacy.
>>>>> That is a substantially larger change, since you'd now be
>>>>> relocating nearly every remaining driver, i.e. all the
>>>>> relatively modern 100M and GigE drivers.
>>>>
>>>
>>> I am not particularly a fan of making a "legacy" directory and moving
>>> old drivers into it.  Just because this is very subjective, if you say
>>> "drivers which are X years old and not used much" is vague and depending
>>> on who you ask would get varying results.  But if you were to were to
>>> define legacy as all ISA, EISA and MCA drivers (not based on their use)
>>> would be better.
>>
>> I think that being subjective can be an advantage.  There may
>> be some debate on whether X is legacy or not, but I see no harm
>> in that.  On the other hand, I see binding ourselves to concrete
>> inflexible rules as a disadvantage.
>>
> 
> I am not disagreeing that we need to be flexible, and to organize the
> directory structure in a logical way does not equate to "concrete and
> inflexible".
> 
> I brought the topic of organizing the /drivers/net directory up at
> NetConf/Plumbers and here is what came about the discussion...

Thanks for the update, I wasn't aware that happened.

> 
> Joe and I are working to organize the drivers into
> /drivers/net/<technology>  directories and to cleanup the Kconfig to
> reflect the organization.  Ethernet drivers will be in
> /drivers/net/ethernet, and so on.  I brought up your suggestion to
> making a "legacy" directory and those present did not like the idea.

Interesting.  I would have not came to that conclusion based on
the feedback on netdev@vger alone.  Oh well, if that was the
consensus then I'm not going to argue with it.

> In short, there is no advantage to this type of organization and
> having the drivers reside in their current location or in the model of
> /drivers/net/<technology>  does not cause any problems
  
[...]

>>>>
>>>> There are arch specific directories under various drivers/...
>>>> so I don't see a need to move directories like drivers/net/arm
>>>> or drivers/s390.
>>>
>>> I agree with Joe.
>>
>> I don't think there is any disagreement here on this point.
>> Moving stuff that is already in an appropriate subdir was
>> never part of what I was proposing with drivers/legacy.
>>
>> But if we create subdirs with concrete definitions, then
>> people will most likely be expecting all drivers that match
>> to be in that specific subdir.
> 
> Correct, although I would use "logical organization" versus "concrete
> definitions" and we are working on patches to do the clean up so that
> Ethernet drivers are under /drivers/net/ethernet/*, as well as the

If you do get agreement on subcategories under ethernet for one
reason or another (i.e. vendor grouping), then I'd suggest using
ns8390 as a grouping category - it would lend itself well to
coalescing a lot of legacy drivers in itself.

> other technologies.  For the drivers like vlan, 8021q, bridging, etc
> we will place those in /drivers/net/sw/.  That is the plan at least...
> 
>>
>>>
>>>>
>>>>> With this, I tried to aim for a significant gain (close to 1/3
>>>>> less files) within what I felt was a reasonable sized change
>>>>> set that had a chance of getting an overall OK from folks.
>>>>> Giant "flag-day" type mammoth changesets are a PITA for all.
>>>>
>>>> I believe there's no need for a flag-day.
>>>> File renames could happen gradually or not at all.
>>>>
>>>>
>>>
>>> Again I agree with Joe.
>>
>> Sure, renames can be async, and driven by the individual
>> maintainers of the files, but typically when conversion
>> like events are left open ended (timewise) they tend
>> to drag on for longer times than necessary.  At least in
>> my experience.  If I had sent the RFC with one patch that
>> amounted to a "mkdir", and no actual file moves, I wouldn't
>> have expected much other than a bagful of scorn in return. :)
>> Putting it to use and showing a real cleanup is where the
>> value became really apparent, I think.
>>
> 
> We are hoping not to drag this out and plan on getting this into
> 2.6.38 (net-next) within the couple of weeks.

Sounds good.  In the end, the one thing I was hoping to see
happen was a bit more organization in drivers/net - and both
solutions should be able to provide this.

Paul.

> 
>> In any case, I still think this is worthwhile, and in the
>> absence of an alternate proposal that gets a higher level
>> of universal agreement, I'm hoping we can still do this.
>> I've got a follow on commit ready that factors a lot of
>> the legacy related probe code out of Space.c too.
>>
>> Regardless of which way it goes, thanks for the feedback.
>> Paul.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 
> 

