From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA
 drivers
Date: Thu, 04 Nov 2010 17:20:47 -0400
Message-ID: <4CD323AF.20609@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>	 <1288316896.1836.41.camel@Joe-Laptop>  <4CCB3BF1.7070000@windriver.com>	 <1288390127.28828.225.camel@Joe-Laptop> <1288396919.15283.23.camel@jtkirshe-MOBL1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43228 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830Ab0KDVUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 17:20:52 -0400
In-Reply-To: <1288396919.15283.23.camel@jtkirshe-MOBL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-10-29 08:01 PM, Jeff Kirsher wrote:
> On Fri, 2010-10-29 at 15:08 -0700, Joe Perches wrote:
>> On Fri, 2010-10-29 at 17:26 -0400, Paul Gortmaker wrote:
>>> On 10-10-28 09:48 PM, Joe Perches wrote:
>>>> On Thu, 2010-10-28 at 21:19 -0400, Paul Gortmaker wrote:
>>>>> The drivers/net dir has a lot of files - originally there were
>>>>> no subdirs, but at least now subdirs are being used effectively.
>>>>> But the original drivers from 10+ years ago are still right
>>>>> there at the top.  This series creates a drivers/net/legacy dir.
>>>> I like this idea.
>>>> I suggest a bit of a further grouping by using a
>>>> drivers/net/ethernet directory and putting those
>>>> legacy drivers in a new subdirectory
>>>> drivers/net/ethernet/legacy.
>>> That is a substantially larger change, since you'd now be
>>> relocating nearly every remaining driver, i.e. all the
>>> relatively modern 100M and GigE drivers.
>>
> 
> I am not particularly a fan of making a "legacy" directory and moving
> old drivers into it.  Just because this is very subjective, if you say
> "drivers which are X years old and not used much" is vague and depending
> on who you ask would get varying results.  But if you were to were to
> define legacy as all ISA, EISA and MCA drivers (not based on their use)
> would be better.

I think that being subjective can be an advantage.  There may
be some debate on whether X is legacy or not, but I see no harm
in that.  On the other hand, I see binding ourselves to concrete
inflexible rules as a disadvantage.

For example, look at the sister directory, drivers/serial -- the
venerable 8250 UART continues to support ISA-like mapped 0x3f8/0x2f8
PIO devices such as those on the ISA MultiIO/IDE cards first appearing
in 80286 computers.  But we probably don't want to shuffle that off to
a legacy dir, given that nearly every embedded CPU manufacturer has a
SoC 8250 UART implementation of their own, and it remains in high use.

> 
> But if a legacy directory was to be made, I like Joe's suggestion of
> drivers/net/ethernet/legacy.

If we extend that to being a rule, i.e. drivers/net/*/legacy
then we'd implicitly be advocating creation of things like:

	drivers/net/tokenring/legacy
	drivers/net/arcnet/legacy

Yes, I do imagine you aren't suggesting we do that.  :)

> 
>> Files to not need immediate renames.
>>
>> Renames could happen when the appropriate maintainer
>> wants to or gets coerced to conform to some new
>> file layout standard.
>>
>> I had submitted a related RFC patch:
>>
>> https://patchwork.kernel.org/patch/244641/
>>
>> and then had some off list discussions
>> with Jeff Kirsher from Intel.
>>
>> Perhaps Jeff will chime in.
>>
>>> Plus what do you
>>> do with the sb1000 - create drivers/cablemodem/legacy
>>> just for one file?
>>
>> I never looked at that particular driver before.
>> Maybe.  I don't have a strong opinion.  Leaving
>> it where it is might be OK.
>>
>>> Or the ethernet drivers already in
>>> existing subdirs, like arm and pcmcia -- do we move those?
>>
>> Maybe.  If there's no demand, there's no absolute need to
>> move it at all.  I think a reasonable goal is to have some
>> sensible and consistent file layout scheme though.
>>
>> There are arch specific directories under various drivers/...
>> so I don't see a need to move directories like drivers/net/arm
>> or drivers/s390.
> 
> I agree with Joe.

I don't think there is any disagreement here on this point.
Moving stuff that is already in an appropriate subdir was
never part of what I was proposing with drivers/legacy.

But if we create subdirs with concrete definitions, then
people will most likely be expecting all drivers that match
to be in that specific subdir.

> 
>>
>>> With this, I tried to aim for a significant gain (close to 1/3
>>> less files) within what I felt was a reasonable sized change
>>> set that had a chance of getting an overall OK from folks.
>>> Giant "flag-day" type mammoth changesets are a PITA for all.
>>
>> I believe there's no need for a flag-day.
>> File renames could happen gradually or not at all.
>>
>>
> 
> Again I agree with Joe.

Sure, renames can be async, and driven by the individual
maintainers of the files, but typically when conversion
like events are left open ended (timewise) they tend
to drag on for longer times than necessary.  At least in
my experience.  If I had sent the RFC with one patch that
amounted to a "mkdir", and no actual file moves, I wouldn't
have expected much other than a bagful of scorn in return. :)
Putting it to use and showing a real cleanup is where the
value became really apparent, I think.

In any case, I still think this is worthwhile, and in the
absence of an alternate proposal that gets a higher level
of universal agreement, I'm hoping we can still do this.
I've got a follow on commit ready that factors a lot of
the legacy related probe code out of Space.c too.

Regardless of which way it goes, thanks for the feedback.
Paul.
