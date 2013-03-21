From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 17:39:56 -0400 (EDT)
Message-ID: <20130321.173956.1308474437226033128.davem@davemloft.net>
References: <CANP3RGdjmgm10rH4AZAVt8Zx+MjwKkzxZ6hoJYuYmQXEz25qQg@mail.gmail.com>
	<20130321.170511.612698812448620739.davem@davemloft.net>
	<CAEP_g=8pqnVddN1jjZNVQ-POc3ths5DmAnr-9=UYKSpgFGrysQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, dkravkov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com,
	pshelar@nicira.com, hkchu@google.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372Ab3CUVj7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:39:59 -0400
In-Reply-To: <CAEP_g=8pqnVddN1jjZNVQ-POc3ths5DmAnr-9=UYKSpgFGrysQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jesse Gross <jesse@nicira.com>
Date: Thu, 21 Mar 2013 14:37:38 -0700

> On Thu, Mar 21, 2013 at 2:05 PM, David Miller <davem@davemloft.net> w=
rote:
>> From: Maciej =AFenczykowski <maze@google.com>
>> Date: Thu, 21 Mar 2013 13:47:07 -0700
>>
>>> They might create non incrementing IP ID packet sequences on the wi=
re,
>>> and this may prevent GRO from kicking in, but it does not make TSO
>>> non-reversible
>>> (if anything it makes it easy to detect that it happened).
>>
>> This is not an acceptable outcome for any form GSO, it should be
>> completely transparent.  The packets we would have output individual=
ly
>> and those which result from the segmented frame must be
>> indistinguishable.
>=20
> We actually don't set the outer IP ID for GRE packets with the DF bit
> set in the non-GSO/TSO case either (and this is not new behavior).
> Obviously TCP/IP header compression doesn't apply to the GRE packet
> itself.
>=20
> Therefore, I think if the driver is switched to increment the inner
> ID, which it sounds like it can be, then everything should be
> transparent.

That's my impression as well.
