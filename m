From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 1/3] fixed_phy: handle link-down case
Date: Sun, 19 Jul 2015 00:16:25 +0300
Message-ID: <55AAC229.9070903@list.ru>
References: <55A7C45F.1070501@list.ru> <55A7C49E.2020803@list.ru>
 <55A83D86.2030505@gmail.com> <55A8E64A.3040009@list.ru>
 <55A94E5A.9010104@gmail.com> <55A95F83.8010900@list.ru>
 <55A97B51.3030508@gmail.com> <55A98EC5.4040805@list.ru>
 <55A99138.2030905@gmail.com> <55A9956E.4070205@list.ru>
 <55A9B9EF.2030308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp44.i.mail.ru ([94.100.177.104]:46270 "EHLO smtp44.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750853AbbGRVQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jul 2015 17:16:36 -0400
In-Reply-To: <55A9B9EF.2030308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

18.07.2015 05:29, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Le 07/17/15 16:53, Stas Sergeev a =C3=A9crit :
>> 18.07.2015 02:35, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> On 17/07/15 16:24, Stas Sergeev wrote:
>>>> 18.07.2015 01:01, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>>> On 17/07/15 13:03, Stas Sergeev wrote:
>>>>>> 17.07.2015 21:50, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>>>>>> On 17/07/15 04:26, Stas Sergeev wrote:
>>>>>>>> 17.07.2015 02:25, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
>>>>>>>>> On 16/07/15 07:50, Stas Sergeev wrote:
>>>>>>>>>> Currently fixed_phy driver recognizes only the link-up state=
=2E
>>>>>>>>>> This simple patch adds an implementation of link-down state.
>>>>>>>>>> It fixes the status registers when link is down, and also al=
lows
>>>>>>>>>> to register the fixed-phy with link down without specifying =
the
>>>>>>>>>> speed.
>>>>>>>>> This patch still breaks my setups here, e.g:
>>>>>>>>> drivers/net/dsa/bcm_sf2.c,
>>>>>>>>> but I will look into it.
>>>>>>>>>
>>>>>>>>> Do we really need this for now for your two other patches to =
work
>>>>>>>>> properly, or is it just nicer to have?
>>>>>>>> Yes, absolutely.
>>>>>>>> Otherwise registering fixed phy will return -EINVAL
>>>>>>>> because of the missing link speed (even though the link
>>>>>>>> is down).
>>>>>>> Ok, I see the problem that you have now. Arguably you could say=
 that
>>>>>>> according to the fixed-link binding, speed needs to be specifie=
d and
>>>>>>> the
>>>>>>> code correctly errors out with such an error if you do not spec=
ify
>>>>>>> it. I
>>>>>> Aren't you missing the fact that .link=3D0?
>>>>>> I think what you say is true only for the link-up case, no?
>>>>>> .speed=3D=3D0 is valid for link-down IMHO: no link - zero speed.
>>>>> Pardon me being very dense and stupid here, but your problem is t=
hat
>>>>> the
>>>>> "speed" parameter is not specified in your DT,
>>>> Not even a fixed-link at all, since the latest patches.
>>>> I removed fixed-link defs from my DT.
>>> Hummm, okay, so you just have the inband-status property and that's=
 it,
>>> not even a fixed-link node anymore, right? How does
>>> mvneta_fixed_link_update() work then since it needs a fixed PHY to =
be
>>> registered?
>> You can see it from my patch:
>> ---
>>
>> +    err =3D of_property_read_string(np, "managed", &managed);
>> +    if (err =3D=3D 0) {
>> +        if (strcmp(managed, "in-band-status") =3D=3D 0) {
>> +            /* status is zeroed, namely its .link member */
>> +            phy =3D fixed_phy_register(PHY_POLL, &status, np);
>> +            return IS_ERR(phy) ? PTR_ERR(phy) : 0;
>> +        }
>> +    }
>>
>> ---
>> which is the hunk added to the of_phy_register_fixed_link().
>> So in that case we register fixed-phy, but do not parse the fixed-li=
nk.
> Ok, I missed that part. Could not you just override everything that i=
s
> needed here to get past the point where you register your fixed PHY e=
ven
> with link =3D 0, this will be discarded anyway once you start in-band
> negotiation.
Maybe my English is bad, but I have problems understanding
some of your senteneces. What do you mean?
If you meant to re-use the existing registration code instead
of adding a new hunk, please note that there is no fixed-link
node at all, so we do not even enter the parsing code block.
As such, there is nothing to override.

> I will work on something anyway.=20
Thanks, hope to hear from you soon.
This stream of regressions is disturbing. :)
Should finally be fixed for real.
