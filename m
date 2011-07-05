From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 08:21:15 +0200
Message-ID: <1309846875.2720.43.camel@edumazet-laptop>
References: <20110704.212014.236340473910292460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48515 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633Ab1GEGVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 02:21:20 -0400
Received: by wyg8 with SMTP id 8so3762483wyg.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 23:21:19 -0700 (PDT)
In-Reply-To: <20110704.212014.236340473910292460.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 juillet 2011 =C3=A0 21:20 -0700, David Miller a =C3=A9crit =
:
> Fanouts allow packet capturing to be demuxed to a set of AF_PACKET
> sockets.  Two fanout policies are implemented:
>=20
> 1) Hashing based upon skb->rxhash

=2E..

> +
> +static struct sock *fanout_demux_hash(struct packet_fanout *f, struc=
t sk_buff *skb)
> +{
> +	u32 idx, hash =3D skb->rxhash;
> +
> +	idx =3D ((u64)hash * f->num_members) >> 32;
> +
> +	return f->arr[idx];
> +}
> +

rxhash is 0 unless skb_get_rxhash() was called, or some NIC set it in R=
X
path.



