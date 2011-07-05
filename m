From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 00:48:51 -0700 (PDT)
Message-ID: <20110705.004851.1206054353953628931.davem@davemloft.net>
References: <20110704.212014.236340473910292460.davem@davemloft.net>
	<1309846875.2720.43.camel@edumazet-laptop>
	<4E12B5A6.2020802@inliniac.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: victor@inliniac.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879Ab1GEHs5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 03:48:57 -0400
In-Reply-To: <4E12B5A6.2020802@inliniac.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Victor Julien <victor@inliniac.net>
Date: Tue, 05 Jul 2011 08:56:38 +0200

> On 07/05/2011 08:21 AM, Eric Dumazet wrote:
>> Le lundi 04 juillet 2011 =E0 21:20 -0700, David Miller a =E9crit :
>>> Fanouts allow packet capturing to be demuxed to a set of AF_PACKET
>>> sockets.  Two fanout policies are implemented:
>>>
>>> 1) Hashing based upon skb->rxhash
>>=20
>> ...
>>=20
>>> +
>>> +static struct sock *fanout_demux_hash(struct packet_fanout *f, str=
uct sk_buff *skb)
>>> +{
>>> +	u32 idx, hash =3D skb->rxhash;
>>> +
>>> +	idx =3D ((u64)hash * f->num_members) >> 32;
>>> +
>>> +	return f->arr[idx];
>>> +}
>>> +
>>=20
>> rxhash is 0 unless skb_get_rxhash() was called, or some NIC set it i=
n RX
>> path.
>>=20
>=20
> Is this still also true for IP fragments?

I have a plan to fix this.  But what I've posted will work as you want
it to for everything else.
