From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCHv2] net/ipv6: add sysctl option accept_ra_hop_limit
Date: Wed, 29 Jul 2015 11:14:18 +0900
Message-ID: <55B836FA.7070106@miraclelinux.com>
References: <1437978942-7047-1-git-send-email-liuhangbin@gmail.com>	<55B6C3AF.1050504@miraclelinux.com>	<CAPwn2JSk0P8n+aSxTGiU0Q2RSSbZ52NVZxOS+yURpor2YQVySQ@mail.gmail.com>	<55B6FDD0.4020904@miraclelinux.com> <CAPwn2JTRvN7pzSxz4TMXC7FNWxbH0PYPPoOjpRpM_rCigoiFeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hideaki.yoshifuji@miraclelinux.com,
	network dev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34187 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbbG2COW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 22:14:22 -0400
Received: by pacan13 with SMTP id an13so80565790pac.1
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 19:14:21 -0700 (PDT)
In-Reply-To: <CAPwn2JTRvN7pzSxz4TMXC7FNWxbH0PYPPoOjpRpM_rCigoiFeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hangbin Liu wrote:
> 2015-07-28 11:58 GMT+08:00 YOSHIFUJI Hideaki
> <hideaki.yoshifuji@miraclelinux.com>:
>> Hi,
>>
>> Hangbin Liu wrote:
>>> 2015-07-28 7:50 GMT+08:00 YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E
>>> <hideaki.yoshifuji@miraclelinux.com>:
>>>> Hi,
>>>>
>>>> Hangbin Liu wrote:
>>>>> Commit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interfa=
ce")
>>>>> disabled accept hop limit from RA if it is higher than the curren=
t hop
>>>>> limit for security stuff. But this behavior kind of break the RFC=
 definition.
>>>>>
>>>>> RFC 4861, 6.3.4.  Processing Received Router Advertisements
>>>>>    If the received Cur Hop Limit value is non-zero, the host SHOU=
LD set
>>>>>    its CurHopLimit variable to the received value.
>>>>>
>>>>> So add sysctl option accept_ra_hop_limit to let user choose wheth=
er accept
>>>>> hop limit info in RA.
>>>>>
>>>>
>>>> How about introducing "minimum hop limit", instead?
>>>
>>> Hi Yoshifuji,
>>>
>>> This is a good idea. Maybe this can be another sysctl option?
>>>
>>> The minimum hop limit can be an enhancement of the security issue, =
then we will
>>> not only increase the hop limit, but also could decrease it in the
>>> range of values we
>>> accept.
>>>
>>> On the other hand, with this patch, we can enable, disable or partl=
y
>>> enable accept
>>> hop limit. If we only use "minimum hop limit", people could not use=
 a static hop
>>> limit value.
>>>
>>> May be we use a =E2=80=9Chop limit range" instead? How do you think=
?
>>
>> I think name of sysctl is the same as you suggested and change the
>> semantics.  default value is 0 to accept all hotlimit value
>> as before and people can set it to 32 (for example) to reject
>> too-small hoplimit (0-31).
>=20
> OK, then I will try submit a "minimum hop limit", thanks for your sug=
gestion :)

accept_ra_min_hop_limit would be better as we have
accept_ra_rt_info_max_plen.

>=20
> Regards
> Hangbin
>>
>> --yoshfuji
>>
>>>
>>> Thanks
>>> Hangbin
>>>
>>>>
>>>> |commit 6fd99094de2b83d1d4c8457f2c83483b2828e75a
>>>> |Author: D.S. Ljungmark <ljungmark@modio.se>
>>>> |Date:   Wed Mar 25 09:28:15 2015 +0100
>>>> |
>>>> |    ipv6: Don't reduce hop limit for an interface
>>>> :
>>>> |    RFC 3756, Section 4.2.7, "Parameter Spoofing"
>>>> |
>>>> :
>>>> |   >   As an example, one possible approach to mitigate this thre=
at is to
>>>> |    >   ignore very small hop limits.  The nodes could implement =
a
>>>> |    >   configurable minimum hop limit, and ignore attempts to se=
t it below
>>>> |    >   said limit.
>>
>> --
>> Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
>> Technical Division, MIRACLE LINUX CORPORATION

--=20
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
