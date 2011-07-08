From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 08 Jul 2011 12:27:42 -0700 (PDT)
Message-ID: <20110708.122742.1006323245708104141.davem@davemloft.net>
References: <CABrhC0kaRCpvmKw=TdPZ+7dRFzdcrjF7hoc-VhbtAfXu=WBU_Q@mail.gmail.com>
	<20110708.110659.1816173367050101549.davem@davemloft.net>
	<CAL1RGDWbCi_nE8tRp9zyX3Z1yBHKP9ygxNV6TNKp4Up+0g2EPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johnwheffner@gmail.com, mj@ucw.cz, netdev@vger.kernel.org
To: roland@purestorage.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802Ab1GHT2H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 15:28:07 -0400
In-Reply-To: <CAL1RGDWbCi_nE8tRp9zyX3Z1yBHKP9ygxNV6TNKp4Up+0g2EPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Roland Dreier <roland@purestorage.com>
Date: Fri, 8 Jul 2011 12:26:17 -0700

> On Fri, Jul 8, 2011 at 11:06 AM, David Miller <davem@davemloft.net> w=
rote:
>> Ok, there was also an unintended bug in my original patch,
>> I lost the bottom 8 bits in the fold, the hash function
>> should instead be:
>>
>> +static inline u32 arp_hashfn(u32 key, const struct net_device *dev,=
 u32 hash_rnd)
>> +{
>> + =A0 =A0 =A0 u32 val =3D key ^ dev->ifindex ^ hash_rnd;
>> +
>> + =A0 =A0 =A0 return val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24);
>> +}
>=20
> Doesn't seem to matter much -- this is now equivalent to
>=20
>       a =3D key ^ dev->ifindex
>        return (a ^ (a >> 8) ^ (a >> 16) ^ (a >> 24))           // (1)
>             ^ (rnd ^ (rnd >> 8) ^ (rnd >> 16) ^ (rnd >> 24))   // (2)
>=20
> where again the attacker controls (1), and (2) is a constant.

Right, but how can you attack it?  Show me how you can grow
a hash chain of arbitrary length by modulating the key in
a deterministic way.

Nobody has done this yet.
