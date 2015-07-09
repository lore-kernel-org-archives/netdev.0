From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 1/2] of_mdio: add new DT property 'link' for fixed-link
Date: Fri, 10 Jul 2015 00:43:05 +0300
Message-ID: <559EEAE9.4000806@list.ru>
References: <559EB0A4.5080101@list.ru> <559EB1A6.1090008@list.ru>
 <559EBC59.6020003@gmail.com> <559EDD0C.7020907@list.ru>
 <559EE45C.4040408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Grant Likely <grant.likely@linaro.org>,
	devicetree@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp22.mail.ru ([94.100.181.177]:40150 "EHLO smtp22.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892AbbGIVn1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 17:43:27 -0400
In-Reply-To: <559EE45C.4040408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

10.07.2015 00:15, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 09/07/15 13:43, Stas Sergeev wrote:
>> 09.07.2015 21:24, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> (there is no such thing as linux-net@vger.kernel.org, please remove=
 it
>>> from your future submissions).
>>>
>>> On 09/07/15 10:38, Stas Sergeev wrote:
>>>> Currently for fixed-link the link state is always set to UP.
>>> Not quite true, this is always a driver decision to make.
>> But what about this part of of_mdio.c:of_phy_register_fixed_link():
>> ---
>>
>>       fixed_link_node =3D of_get_child_by_name(np, "fixed-link");
>>       if (fixed_link_node) {
>>          status.link =3D 1
>>
>> ---
> This seems like a logical consequence of finding a "fixed-link" prope=
rty
> for the DT node of interest. If no such property exist, then we do no=
t
> set anything.
>
>>>> This patch introduces the new property 'link' that accepts the
>>>> following string arguments: "up", "down" and "auto".
>>>> "down" may be needed if the link is physically unconnected.
>>> In which case you probably do not even care about inserting such a
>>> property in the first place, do you? What would be the value of for=
cibly
>>> having a link permanently down (not counting loopback)?
>> The DTs have a common parts that are included by other
>> parts. So if you include the definition of your SoC that have
>> all ethernets defined, and you only set up the external things
>> like PHYs, then I would see a potential use for "down".
> "down" is equivalent to using a status =3D "disabled", in fact the la=
tter
> is much better since you can even conserve energy and resources by no=
t
> enabling something which is not usable.
OK, agree.
So I'll probably go for something like
autoneg =3D 1 | 0;

>> This doesn't work.
>> It appears even if the driver supports it and wants to use it, the
>> PHY HW may simply not generate the inband status. This is actually
>> the whole point why we have a regression now. It is _currently_
>> a driver decision, and that doesn't work for some people.
>> The point of this patch set is to make it a DT decision instead.
> Then, if the in-band status indication is not reliable (which really
> should be completely understood),
Agree!
But this is not something I can help with.
Sebastien Rannou reports the problem, please ask him whatever
you see fits to get a better understanding of a problem.
The fact that his HW does not generate the inband status, is
_my own guess_.

>   you can just ignore the in-band status
> and use all the parameter in a 'fixed-link' property, should not we?
I don't think there is any way at all to find out if the inband stat is
usable or not. I think only the user (or manufacturer) can decide
on that. If there is any way to do a guess-work, that would be an
entirely different story.
