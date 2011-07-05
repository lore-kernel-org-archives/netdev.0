From: Victor Julien <victor@inliniac.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 08:56:38 +0200
Message-ID: <4E12B5A6.2020802@inliniac.net>
References: <20110704.212014.236340473910292460.davem@davemloft.net> <1309846875.2720.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-27.netfusion.at ([83.215.238.27]:33480 "EHLO
	tulpe.vuurmuur.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775Ab1GEG5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 02:57:06 -0400
In-Reply-To: <1309846875.2720.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2011 08:21 AM, Eric Dumazet wrote:
> Le lundi 04 juillet 2011 =C3=A0 21:20 -0700, David Miller a =C3=A9cri=
t :
>> Fanouts allow packet capturing to be demuxed to a set of AF_PACKET
>> sockets.  Two fanout policies are implemented:
>>
>> 1) Hashing based upon skb->rxhash
>=20
> ...
>=20
>> +
>> +static struct sock *fanout_demux_hash(struct packet_fanout *f, stru=
ct sk_buff *skb)
>> +{
>> +	u32 idx, hash =3D skb->rxhash;
>> +
>> +	idx =3D ((u64)hash * f->num_members) >> 32;
>> +
>> +	return f->arr[idx];
>> +}
>> +
>=20
> rxhash is 0 unless skb_get_rxhash() was called, or some NIC set it in=
 RX
> path.
>=20

Is this still also true for IP fragments?

--=20
---------------------------------------------
Victor Julien
http://www.inliniac.net/
PGP: http://www.inliniac.net/victorjulien.asc
---------------------------------------------

