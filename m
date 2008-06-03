From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 3 Jun 2008 12:37:35 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl>
References: <20080603080812.GA4514@ff.dom.local>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-109685715-1212489455=:3438"
Cc: kaber@trash.net, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:41846 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbYFCKhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 06:37:51 -0400
In-Reply-To: <20080603080812.GA4514@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-109685715-1212489455=:3438
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 3 Jun 2008, Jarek Poplawski wrote:

> On 03-06-2008 00:09, Krzysztof Oledzki wrote:
>> From 4cb8c341fc444afc638cf9ce4efb7e4248e88b5e Mon Sep 17 00:00:00 2001
>> From: Krzysztof Piotr Oledzki <ole@ans.pl>
>> Date: Tue, 3 Jun 2008 00:03:41 +0200
>> Subject: [NET] Fix routing tables with id > 255 for legacy software
>>
>> Most legacy software do not like tables > 255 as rtm_table is u8
>> so tb_id is sent &0xff and it is possible to mismatch for example
>> table 510 with table 254 (main).
>>
>> This patch introduces RT_TABLE_COMPAT=3D253 so the code uses it if
>> tb_id > 255. It makes such old applications happy, new
>> ones are still able to use RTA_TABLE to get a proper table id.
>>
>
> Probably, as usual, some people will grumble this breaks their scripts,
> so, probably, some if or ifdef is needed?
Why? If scripts are based on a recent version of iproute2 that uses=20
RTA_TABLE then everything should work, especially there is no way to use=20
tables with id > 255 with old iproute2.

> BTW, I wonder, how these old appliction would treat RT_TABLE_UNSPEC=20
> instead.

Such old appliction is for example zebra/quagga: it asks for all routes,=20
does not know about RTA_TABLE so uses rtm_table and selects all entries=20
with rtm_table =3D=3D RT_TABLE_MAIN or zebrad.rtm_table_default which is=20
unfortunately 0 by default. So no, RT_TABLE_UNSPEC (0) does not help, even=
=20
makes everythink worse here.

Best regards,

 =09=09=09Krzysztof Ol=EAdzki
---187430788-109685715-1212489455=:3438--
