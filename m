From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCHv2] net/ipv6: add sysctl option accept_ra_hop_limit
Date: Tue, 28 Jul 2015 12:58:08 +0900
Message-ID: <55B6FDD0.4020904@miraclelinux.com>
References: <1437978942-7047-1-git-send-email-liuhangbin@gmail.com>	<55B6C3AF.1050504@miraclelinux.com> <CAPwn2JSk0P8n+aSxTGiU0Q2RSSbZ52NVZxOS+yURpor2YQVySQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hideaki.yoshifuji@miraclelinux.com,
	network dev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35979 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbbG1D6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 23:58:13 -0400
Received: by pdjr16 with SMTP id r16so64185410pdj.3
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 20:58:12 -0700 (PDT)
In-Reply-To: <CAPwn2JSk0P8n+aSxTGiU0Q2RSSbZ52NVZxOS+yURpor2YQVySQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Hangbin Liu wrote:
> 2015-07-28 7:50 GMT+08:00 YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=
=E6=98=8E
> <hideaki.yoshifuji@miraclelinux.com>:
>> Hi,
>>
>> Hangbin Liu wrote:
>>> Commit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface=
")
>>> disabled accept hop limit from RA if it is higher than the current =
hop
>>> limit for security stuff. But this behavior kind of break the RFC d=
efinition.
>>>
>>> RFC 4861, 6.3.4.  Processing Received Router Advertisements
>>>    If the received Cur Hop Limit value is non-zero, the host SHOULD=
 set
>>>    its CurHopLimit variable to the received value.
>>>
>>> So add sysctl option accept_ra_hop_limit to let user choose whether=
 accept
>>> hop limit info in RA.
>>>
>>
>> How about introducing "minimum hop limit", instead?
>=20
> Hi Yoshifuji,
>=20
> This is a good idea. Maybe this can be another sysctl option?
>=20
> The minimum hop limit can be an enhancement of the security issue, th=
en we will
> not only increase the hop limit, but also could decrease it in the
> range of values we
> accept.
>=20
> On the other hand, with this patch, we can enable, disable or partly
> enable accept
> hop limit. If we only use "minimum hop limit", people could not use a=
 static hop
> limit value.
>=20
> May be we use a =E2=80=9Chop limit range" instead? How do you think?

I think name of sysctl is the same as you suggested and change the
semantics.  default value is 0 to accept all hotlimit value
as before and people can set it to 32 (for example) to reject
too-small hoplimit (0-31).

--yoshfuji

>=20
> Thanks
> Hangbin
>=20
>>
>> |commit 6fd99094de2b83d1d4c8457f2c83483b2828e75a
>> |Author: D.S. Ljungmark <ljungmark@modio.se>
>> |Date:   Wed Mar 25 09:28:15 2015 +0100
>> |
>> |    ipv6: Don't reduce hop limit for an interface
>> :
>> |    RFC 3756, Section 4.2.7, "Parameter Spoofing"
>> |
>> :
>> |   >   As an example, one possible approach to mitigate this threat=
 is to
>> |    >   ignore very small hop limits.  The nodes could implement a
>> |    >   configurable minimum hop limit, and ignore attempts to set =
it below
>> |    >   said limit.

--=20
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
