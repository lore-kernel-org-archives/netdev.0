From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 3 Jun 2008 20:29:49 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806032011070.3438@bizon.gios.gov.pl>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl>
 <20080603113343.GA4714@ff.dom.local> <48453C70.1040303@trash.net>
 <Pine.LNX.4.64.0806031449540.3438@bizon.gios.gov.pl> <484542B5.4070401@trash.net>
 <Pine.LNX.4.64.0806031617310.3438@bizon.gios.gov.pl> <20080603174941.GA2727@ami.dom.local>
 <48458652.7020309@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-486206623-1212517789=:3438"
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:41823 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298AbYFCSaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 14:30:00 -0400
In-Reply-To: <48458652.7020309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-486206623-1212517789=:3438
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 3 Jun 2008, Patrick McHardy wrote:

> Jarek Poplawski wrote:
>> On Tue, Jun 03, 2008 at 05:15:04PM +0200, Krzysztof Oledzki wrote:
>>>=20
>>> On Tue, 3 Jun 2008, Patrick McHardy wrote:
>> ...
>>>> Your patch makes it more predictable, so I'm not completely
>>>> opposed, but still its just a workaround.
>>> Indeed - it is a workaround but I believe we need it.
>>>=20
>>=20
>> IMHO, adding a safety with e.g. CONFIG_IP_FIB_COMPAT_DEPRECATED
>> (default N) for one stable, letting to change this back in some
>> (probably nonexistent) strange cases, should be enough to keep up
>> appearances...
>
>
> Mhh .. I don't think this is a good solution.

I second that. If you know that you need this option then you don't need=20
it as you may avoid selected tables.

> Things can only break if you actually use the new feature, and if you=20
> do, you should simply make sure that all software running can deal with=
=20
> it. Fixing the routing daemons should be a triviality.

Indeed, it is trivial and I even have a small patch for quagga I'm going=20
to push to the upstream soon. However the problem is the non intuitive=20
behavior of old applications that may lead into a critical network outage=
=20
(been there, done that) and my patch is supposed to minimize such a=20
possibility. Without special knowledge it is not obvious that that routes=
=20
in 256, 510, etc tables may be handle as routes in RT_TABLE_MAIN table.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-486206623-1212517789=:3438--
