From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA drivers
Date: Thu, 4 Nov 2010 19:28:06 -0700
Message-ID: <AANLkTim2yH7eAqqYQW+JVC5GtFR5mX4uZnMa02+yubFk@mail.gmail.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
	<1288316896.1836.41.camel@Joe-Laptop>
	<4CCB3BF1.7070000@windriver.com>
	<1288390127.28828.225.camel@Joe-Laptop>
	<1288396919.15283.23.camel@jtkirshe-MOBL1>
	<4CD323AF.20609@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:38711 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087Ab0KEC2H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 22:28:07 -0400
Received: by ywc21 with SMTP id 21so1914996ywc.19
        for <netdev@vger.kernel.org>; Thu, 04 Nov 2010 19:28:06 -0700 (PDT)
In-Reply-To: <4CD323AF.20609@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 4, 2010 at 14:20, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
> On 10-10-29 08:01 PM, Jeff Kirsher wrote:
>> On Fri, 2010-10-29 at 15:08 -0700, Joe Perches wrote:
>>> On Fri, 2010-10-29 at 17:26 -0400, Paul Gortmaker wrote:
>>>> On 10-10-28 09:48 PM, Joe Perches wrote:
>>>>> On Thu, 2010-10-28 at 21:19 -0400, Paul Gortmaker wrote:
>>>>>> The drivers/net dir has a lot of files - originally there were
>>>>>> no subdirs, but at least now subdirs are being used effectively.
>>>>>> But the original drivers from 10+ years ago are still right
>>>>>> there at the top. =C2=A0This series creates a drivers/net/legacy=
 dir.
>>>>> I like this idea.
>>>>> I suggest a bit of a further grouping by using a
>>>>> drivers/net/ethernet directory and putting those
>>>>> legacy drivers in a new subdirectory
>>>>> drivers/net/ethernet/legacy.
>>>> That is a substantially larger change, since you'd now be
>>>> relocating nearly every remaining driver, i.e. all the
>>>> relatively modern 100M and GigE drivers.
>>>
>>
>> I am not particularly a fan of making a "legacy" directory and movin=
g
>> old drivers into it. =C2=A0Just because this is very subjective, if =
you say
>> "drivers which are X years old and not used much" is vague and depen=
ding
>> on who you ask would get varying results. =C2=A0But if you were to w=
ere to
>> define legacy as all ISA, EISA and MCA drivers (not based on their u=
se)
>> would be better.
>
> I think that being subjective can be an advantage. =C2=A0There may
> be some debate on whether X is legacy or not, but I see no harm
> in that. =C2=A0On the other hand, I see binding ourselves to concrete
> inflexible rules as a disadvantage.
>

I am not disagreeing that we need to be flexible, and to organize the
directory structure in a logical way does not equate to "concrete and
inflexible".

I brought the topic of organizing the /drivers/net directory up at
NetConf/Plumbers and here is what came about the discussion...

Joe and I are working to organize the drivers into
/drivers/net/<technology> directories and to cleanup the Kconfig to
reflect the organization.  Ethernet drivers will be in
/drivers/net/ethernet, and so on.  I brought up your suggestion to
making a "legacy" directory and those present did not like the idea.
In short, there is no advantage to this type of organization and
having the drivers reside in their current location or in the model of
/drivers/net/<technology> does not cause any problems

> For example, look at the sister directory, drivers/serial -- the
> venerable 8250 UART continues to support ISA-like mapped 0x3f8/0x2f8
> PIO devices such as those on the ISA MultiIO/IDE cards first appearin=
g
> in 80286 computers. =C2=A0But we probably don't want to shuffle that =
off to
> a legacy dir, given that nearly every embedded CPU manufacturer has a
> SoC 8250 UART implementation of their own, and it remains in high use=
=2E
>
>>
>> But if a legacy directory was to be made, I like Joe's suggestion of
>> drivers/net/ethernet/legacy.
>
> If we extend that to being a rule, i.e. drivers/net/*/legacy
> then we'd implicitly be advocating creation of things like:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0drivers/net/tokenring/legacy
> =C2=A0 =C2=A0 =C2=A0 =C2=A0drivers/net/arcnet/legacy
>
> Yes, I do imagine you aren't suggesting we do that. =C2=A0:)
>
>>
>>> Files to not need immediate renames.
>>>
>>> Renames could happen when the appropriate maintainer
>>> wants to or gets coerced to conform to some new
>>> file layout standard.
>>>
>>> I had submitted a related RFC patch:
>>>
>>> https://patchwork.kernel.org/patch/244641/
>>>
>>> and then had some off list discussions
>>> with Jeff Kirsher from Intel.
>>>
>>> Perhaps Jeff will chime in.
>>>
>>>> Plus what do you
>>>> do with the sb1000 - create drivers/cablemodem/legacy
>>>> just for one file?
>>>
>>> I never looked at that particular driver before.
>>> Maybe. =C2=A0I don't have a strong opinion. =C2=A0Leaving
>>> it where it is might be OK.
>>>
>>>> Or the ethernet drivers already in
>>>> existing subdirs, like arm and pcmcia -- do we move those?
>>>
>>> Maybe. =C2=A0If there's no demand, there's no absolute need to
>>> move it at all. =C2=A0I think a reasonable goal is to have some
>>> sensible and consistent file layout scheme though.
>>>
>>> There are arch specific directories under various drivers/...
>>> so I don't see a need to move directories like drivers/net/arm
>>> or drivers/s390.
>>
>> I agree with Joe.
>
> I don't think there is any disagreement here on this point.
> Moving stuff that is already in an appropriate subdir was
> never part of what I was proposing with drivers/legacy.
>
> But if we create subdirs with concrete definitions, then
> people will most likely be expecting all drivers that match
> to be in that specific subdir.

Correct, although I would use "logical organization" versus "concrete
definitions" and we are working on patches to do the clean up so that
Ethernet drivers are under /drivers/net/ethernet/*, as well as the
other technologies.  For the drivers like vlan, 8021q, bridging, etc
we will place those in /drivers/net/sw/.  That is the plan at least...

>
>>
>>>
>>>> With this, I tried to aim for a significant gain (close to 1/3
>>>> less files) within what I felt was a reasonable sized change
>>>> set that had a chance of getting an overall OK from folks.
>>>> Giant "flag-day" type mammoth changesets are a PITA for all.
>>>
>>> I believe there's no need for a flag-day.
>>> File renames could happen gradually or not at all.
>>>
>>>
>>
>> Again I agree with Joe.
>
> Sure, renames can be async, and driven by the individual
> maintainers of the files, but typically when conversion
> like events are left open ended (timewise) they tend
> to drag on for longer times than necessary. =C2=A0At least in
> my experience. =C2=A0If I had sent the RFC with one patch that
> amounted to a "mkdir", and no actual file moves, I wouldn't
> have expected much other than a bagful of scorn in return. :)
> Putting it to use and showing a real cleanup is where the
> value became really apparent, I think.
>

We are hoping not to drag this out and plan on getting this into
2.6.38 (net-next) within the couple of weeks.

> In any case, I still think this is worthwhile, and in the
> absence of an alternate proposal that gets a higher level
> of universal agreement, I'm hoping we can still do this.
> I've got a follow on commit ready that factors a lot of
> the legacy related probe code out of Space.c too.
>
> Regardless of which way it goes, thanks for the feedback.
> Paul.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>



--=20
Cheers,
Jeff
