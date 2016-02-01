From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Sun, 31 Jan 2016 16:39:35 -0800
Message-ID: <56AEA947.409@gmail.com>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
 <1454286240.7627.160.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sowmini.varadhan@oracle.com, kernel-team@fb.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36356 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932824AbcBAAji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 19:39:38 -0500
Received: by mail-oi0-f43.google.com with SMTP id j125so15440368oih.3
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 16:39:38 -0800 (PST)
In-Reply-To: <1454286240.7627.160.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 31/01/2016 16:24, Eric Dumazet a =C3=A9crit :
> On Sun, 2016-01-31 at 13:37 -0800, Tom Herbert wrote:
>> Call get_unaligned_be32 when we access 32-bit fields in
>> __skb_flow_dissect. At the beginning check for unlikely case of
>> 1-byte aligned packet.
>>
>> Note that flow_dissector may be asked to parse packet unaligned
>> fields in two instances:
>>
>> 1) Packet from a driver which is aligned to Ethernet header
>>    (2-byte alignment)
>> 2) Parsing inner headers of a received GRE-TEB packet
>>
>> Testing: Ran super_netperf tests did not see a regression. This was =
on
>> x86 which does not have problems with unaligned data.
>=20
> But this test is absolutely useless, what about testing arches that
> actually care ?
>=20
> I am told all these MIPS based boxes have already not enough cpu powe=
r.

How about the Cavium OCTEON family and Broadcom/Netlogic XLR/XLP, those
are massively multi-core and MIPS64 capable, even though they may not
always run a Linux networking stack, some do.

There are also plenty of ARMv7/ARMv8 devices out there that would
benefit from proper alignment some might end-up using mlx4/5 and intel
cards.

>=20
> It is sad, because none of them use the drivers that might call flow
> dissection (mlx4 and 4 intel drivers)
>=20
> So I would rather fix the cases where flow dissection called from
> eth_get_headlen() with non aligned stuff.
>=20
> And maybe restrict GRE-TEB to platforms with
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=3Dy, since otherwise we need t=
o add
> these unaligned macros in thousands of places in our stacks.
>=20
>=20
>=20


--=20
=46lorian
