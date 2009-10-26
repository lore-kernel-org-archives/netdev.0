From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Mon, 26 Oct 2009 10:05:50 +0200
Message-ID: <4AE5585E.5010108@codefidence.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com>	<1256115421-12714-9-git-send-email-gilad@codefidence.com>	<4ADED6FA.2030502@gmail.com>	<4ADEE119.7020803@codefidence.com>	<4ADF616B.1090405@gmail.com>	<20091022003245.5cd4885c.billfink@mindspring.com>	<4ADFE635.4020109@gmail.com>	<4AE415DD.5050406@codefidence.com> <20091025202114.152b94b8.billfink@mindspring.com> <4AE52DBD.3030805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bill Fink <billfink@mindspring.com>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:47164 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754875AbZJZIF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 04:05:58 -0400
In-Reply-To: <4AE52DBD.3030805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Bill Fink a =E9crit :
>  =20
>> On Sun, 25 Oct 2009, Gilad Ben-Yossef wrote:
>>
>>    =20
>>> Eric Dumazet wrote:
>>>
>>>
>>> I still think having a global kill switch and per route options bet=
ter=20
>>> (basically use the exiting patch but not retire the global kill=20
>>> switch|), but if you must Hgow about we leave the global sysctl as =
they=20
>>> are and just have a two bit route option:
>>>
>>> 0 Use global default
>>> 1 Off
>>> 2 On
>>>
>>> It's kind of funny, because this is what the original patch from=20
>>> Comsleep does and I thought it needlessly complicates things.
>>>
>>> So, what do you say - which will it be?
>>>      =20
>> I personally feel the 2-bit settings are overkill.  What i think
>> makes the most sense is for the global options to act as they always
>> have in the absence of any route specific settings, and for any
>> route specific settings to override the related global settings.
>> This is both simple and maintains backward compatibility.
>>    =20
>
> Backward compatibility is important, very important, if not the most
> important thing. Then usability comes.
>  =20
I tend to agree.
> I know some busy servers where adding/changing a single route makes t=
hem
> go crazy (because of ip route flush cache)
>
> So if a route is overriding a global conf, and the admin wants to mak=
e an
> emergency change during peak hours, he should do it by a global setti=
ng,
> or he wont use at all this new stuff, and stay conservative.
>
> Alternative would be to not trigger the flush of cache when changing
> features flags.
>
>  =20
OK. It really sounds like we should go with my first suggestion: global=
=20
sysctl based kill switches, just as we have now and in addition, the=20
ability to kill TCP options per route. The TCP option will be used if=20
and only if both kill switches (global and per route) are not set.

What we achieve is:

1. Global kill switches work exactly as they do now, whether you use th=
e=20
new per route options or not, so backwards compatible.

2. In addition, if the global kill switch is not in effect, you can als=
o=20
kill the options on a per route basis.

I'm going to send third version of the patch to this effect, minus the=20
new remote DoS possibility that Ilpo pointed out and leaving the global=
=20
sysctl kill switches be.

If you like it, please ACK ;-)

Thanks,
Gilad



--=20
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
=46ax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxolog=
y.net

	"Linux is Ir. Ir, of course, is a form of hypereviscerated Reiyk."
		-- Marc Volovic, linux-il, 14 Dec 2000

