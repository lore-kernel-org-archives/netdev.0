From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 3 Jun 2008 15:03:48 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806031449540.3438@bizon.gios.gov.pl>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl>
 <20080603113343.GA4714@ff.dom.local> <48453C70.1040303@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1451159614-1212498228=:3438"
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:36846 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbYFCND6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 09:03:58 -0400
In-Reply-To: <48453C70.1040303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1451159614-1212498228=:3438
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 3 Jun 2008, Patrick McHardy wrote:

> Jarek Poplawski wrote:
>> On Tue, Jun 03, 2008 at 12:37:35PM +0200, Krzysztof Oledzki wrote:
>>>=20
>> If such an old app uses rtm_table, this 253 table could be used for
>> something and get additional entries after this patch. Another case
>> would be when such an overflow on 0xff is "expected", then old tables
>> would loose their entries. I hope I'm wrong with this, but it looks
>> like admins can do strange things, and then this would be called a
>> regression. So, I think this patch is right if we are sure there are
>> no such cases...
>>=20
>>>> BTW, I wonder, how these old appliction would treat RT_TABLE_UNSPEC=20
>>>> instead.
>>> Such old appliction is for example zebra/quagga: it asks for all routes=
,=20
>>> does not know about RTA_TABLE so uses rtm_table and selects all entries=
=20
>>> with rtm_table =3D=3D RT_TABLE_MAIN or zebrad.rtm_table_default which i=
s=20
>>> unfortunately 0 by default. So no, RT_TABLE_UNSPEC (0) does not help, e=
ven=20
>>> makes everythink worse here.
>>=20
>> I see: so we don't care for these RT_TABLE_COMPAT entries, let only
>> they don't go to _MAIN or _UNSPEC!
>
> Well, if people already use table 253, I guess they might care.

Not really as if pople use a FRA_TABLE aware application they should not=20
notice any difference.

> I'm not convinced this is any better than overflowing.

But if they use FRA_TABLE unaware application than overflowing means=20
mismatching all:
  - N*256 table as RT_TABLE_UNSPEC
  - N*256+253 tables as RT_TABLE_DEFAULT
  - N*256+254 tables as RT_TABLE_MAIN
  - N*256+255 tables as RT_TABLE_LOCAL

And as I just find out, when it happens is quite unexpected and can really=
=20
hurt. :(

> And I still don't see any other way to handle this properly.

Exactly. So that's why I came with above solution, similar to AS_TRANSIT=20
idea used in BGP to handle 16bit -> 32bit ASN transformation.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1451159614-1212498228=:3438--
