From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 02 Jan 2011 23:49:22 +0100
Message-ID: <1294008562.2535.263.camel@edumazet-laptop>
References: <1294007971-18878-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com,
	jj@chaosbits.net, daniel.baluta@gmail.com, jochen@jochen.org
To: stefani@seibold.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38108 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab1ABWta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jan 2011 17:49:30 -0500
In-Reply-To: <1294007971-18878-1-git-send-email-stefani@seibold.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 janvier 2011 =C3=A0 23:39 +0100, stefani@seibold.net a =C3=
=A9crit :
> +
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
> +	if (usk->connections >=3D udpcp_max_connections)
> +		return NULL;
> +
> +	dest =3D kzalloc(sizeof(*dest), sk->sk_allocation);
> +
> +	if (dest) {
> +		usk->connections++;
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

Hmm, so 'connections' is increased, never decreased.

This seems a fatal flaw in this protocol, since a malicious user can
easily fill the list with garbage, and block regular communications.



