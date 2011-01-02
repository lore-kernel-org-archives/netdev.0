From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 02 Jan 2011 17:34:04 +0100
Message-ID: <1293986044.2535.104.camel@edumazet-laptop>
References: <1293982286-15389-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: stefani@seibold.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48587 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348Ab1ABQeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jan 2011 11:34:11 -0500
In-Reply-To: <1293982286-15389-1-git-send-email-stefani@seibold.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 janvier 2011 =C3=A0 16:31 +0100, stefani@seibold.net a =C3=
=A9crit :
> From: Stefani Seibold <stefani@seibold.net>
>=20
> Changelog:
> 31.12.2010 first proposal
> 01.01.2011 code cleanup and fixes suggest by Eric Dumazet
> 02.01.2011 kick away UDP-Lite support
>            change spin_lock_irq into spin_lock_bh
> 	   faster udpcp_release_sock
> 	   base is now linux-next
=2E..

> +/*
> + * Create a new destination descriptor for the given IPV4 address an=
d port
> + */
> +static struct udpcp_dest *new_dest(struct sock *sk, __be32 addr, __b=
e16 port)
> +{
> +	struct udpcp_dest *dest;
> +	struct udpcp_sock *usk =3D udpcp_sk(sk);
> +
> +	dest =3D kzalloc(sizeof(*dest), sk->sk_allocation);
> +
> +	if (dest) {
> +		skb_queue_head_init(&dest->xmit);
> +		dest->addr =3D addr;
> +		dest->port =3D port;
> +		dest->ackmode =3D UDPCP_ACK;
> +		list_add_tail(&dest->list, &usk->destlist);
> +	}
> +
> +	return dest;
> +}
> +

I have not found what prevents a malicious user to make destlist grow
and consume all memory ?



