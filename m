From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Mon, 26 Oct 2009 06:03:57 +0100
Message-ID: <4AE52DBD.3030805@gmail.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com>	<1256115421-12714-9-git-send-email-gilad@codefidence.com>	<4ADED6FA.2030502@gmail.com>	<4ADEE119.7020803@codefidence.com>	<4ADF616B.1090405@gmail.com>	<20091022003245.5cd4885c.billfink@mindspring.com>	<4ADFE635.4020109@gmail.com>	<4AE415DD.5050406@codefidence.com> <20091025202114.152b94b8.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gilad Ben-Yossef <gilad@codefidence.com>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55949 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637AbZJZFEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 01:04:04 -0400
In-Reply-To: <20091025202114.152b94b8.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink a =E9crit :
> On Sun, 25 Oct 2009, Gilad Ben-Yossef wrote:
>=20
>> Eric Dumazet wrote:
>>
>>> Bill Fink a =E9crit :
>>>
>>>  =20
>>>> And as mentioned previously, the global options can be quite usefu=
l
>>>> in certain test scenarios.  I also agree the per route settings ar=
e
>>>> a very useful addition.  I think the global and per route settings
>>>> are complementary and shouldn't be thought of as in conflict with
>>>> one another.
>>>>    =20
>>> Absolutely, global setting is a must when an admin wants a quick pa=
th.
>>>
>>> The more flexible would be to have two bits per route, plus
>>> 2 bits on the global configuration.
>>>
>>> global conf:
>>> 00 : timestamps OFF, unless a route setting is not 00
>>> 01 : timestamps ON, unless a route setting is not 00
>>> 10 : Force timestamps OFF, ignore route settings (emergency sysadmi=
n request)
>>> 11 : Force timestamps ON, ignore route settings=20
>>>
>>> Route settings (used *only* if global setting is 0Y)
>>> 00 : global conf is used
>>> 01 : Force timestamps being OFF for this route
>>> 10 : Force timestamps being ON for this route
>>> 11 : complement global conf
>> Hey, I have no issue to re-spin the patch with this suggestion, if y=
ou=20
>> truly think this is valuable, but would you please consider the=20
>> nightmare of having to just explain this to someone?
>>
>> It sounds to me way too complicated for what it does.
>>
>> I still think having a global kill switch and per route options bett=
er=20
>> (basically use the exiting patch but not retire the global kill=20
>> switch|), but if you must Hgow about we leave the global sysctl as t=
hey=20
>> are and just have a two bit route option:
>>
>> 0 Use global default
>> 1 Off
>> 2 On
>>
>> It's kind of funny, because this is what the original patch from=20
>> Comsleep does and I thought it needlessly complicates things.
>>
>> So, what do you say - which will it be?
>=20
> I personally feel the 2-bit settings are overkill.  What i think
> makes the most sense is for the global options to act as they always
> have in the absence of any route specific settings, and for any
> route specific settings to override the related global settings.
> This is both simple and maintains backward compatibility.

Backward compatibility is important, very important, if not the most
important thing. Then usability comes.

I know some busy servers where adding/changing a single route makes the=
m
go crazy (because of ip route flush cache)

So if a route is overriding a global conf, and the admin wants to make =
an
emergency change during peak hours, he should do it by a global setting=
,
or he wont use at all this new stuff, and stay conservative.

Alternative would be to not trigger the flush of cache when changing
features flags.
