From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 3 Jun 2008 17:15:04 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806031617310.3438@bizon.gios.gov.pl>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl>
 <20080603113343.GA4714@ff.dom.local> <48453C70.1040303@trash.net>
 <Pine.LNX.4.64.0806031449540.3438@bizon.gios.gov.pl> <484542B5.4070401@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-2002133025-1212506104=:3438"
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:38023 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbYFCPPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 11:15:22 -0400
In-Reply-To: <484542B5.4070401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-2002133025-1212506104=:3438
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 3 Jun 2008, Patrick McHardy wrote:

> Krzysztof Oledzki wrote:
>> On Tue, 3 Jun 2008, Patrick McHardy wrote:
>>=20
>>> Well, if people already use table 253, I guess they might care.
>>=20
>> Not really as if pople use a FRA_TABLE aware application they should not=
=20
>> notice any difference.
>
> In that case not of course.
>
>>> I'm not convinced this is any better than overflowing.
>>=20
>> But if they use FRA_TABLE unaware application than overflowing means=20
>> mismatching all:
>>  - N*256 table as RT_TABLE_UNSPEC
>>  - N*256+253 tables as RT_TABLE_DEFAULT
>>  - N*256+254 tables as RT_TABLE_MAIN
>>  - N*256+255 tables as RT_TABLE_LOCAL
>>=20
>> And as I just find out, when it happens is quite unexpected and can real=
ly=20
>> hurt. :(
>>=20
>>> And I still don't see any other way to handle this properly.
>>=20
>> Exactly. So that's why I came with above solution, similar to AS_TRANSIT=
=20
>> idea used in BGP to handle 16bit -> 32bit ASN transformation.
>
> I think the proper solution is what I wrote in the changelog
> entry: fix userspace applications when using extended table
> IDs.

It is unquestionably true, however it may take some time and people may=20
still use old version of such applications for whatsoever reasons.

> Your patch makes it more predictable, so I'm not completely
> opposed, but still its just a workaround.

Indeed - it is a workaround but I believe we need it.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-2002133025-1212506104=:3438--
