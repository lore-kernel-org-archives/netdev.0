From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reduce number of reference taken on sk_refcnt
Date: Sat, 09 May 2009 13:36:10 -0700 (PDT)
Message-ID: <20090509.133610.261544758.davem@davemloft.net>
References: <4A044BE7.3070308@cosmosbay.com>
	<20090508.144859.152310605.davem@davemloft.net>
	<4A057387.4080308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49732
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753052AbZEIUgP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 May 2009 16:36:15 -0400
In-Reply-To: <4A057387.4080308@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 09 May 2009 14:13:59 +0200

> David Miller a =E9crit :
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Fri, 08 May 2009 17:12:39 +0200
>>=20
>>> For example, we can avoid the dst_release() cache miss if this
>>> is done in start_xmit(), and not later in TX completion while freei=
ng skb.
>>> I tried various patches in the past but unfortunatly it seems
>>> only safe way to do this is in the driver xmit itself, not in core
>>> network stack. This would need many patches, one for each driver.
>>=20
>> There might be a way around having to hit every driver.
>>=20
>> The case we can't muck with is when the route will be used.
>> Devices which create this kind of situation can be marked with
>> a flag bit in struct netdevice.  If that flag bit isn't set,
>> you can drop the DST in dev_hard_start_xmit().
>=20
> Yes, this is a possibility, I'll think about it, thank you.
> I'll have to recall which devices would need this flag (loopback for =
sure)..

Another idea is to invert the flag, and set it in places such
as alloc_etherdev*().

This might speed up getting coverage for the most obvious cases.
