From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 02 Jan 2011 23:55:17 +0100
Message-ID: <1294008917.18963.3.camel@wall-e>
References: <1294007971-18878-1-git-send-email-stefani@seibold.net>
	 <1294008562.2535.263.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com,
	jj@chaosbits.net, daniel.baluta@gmail.com, jochen@jochen.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294008562.2535.263.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag, den 02.01.2011, 23:49 +0100 schrieb Eric Dumazet:
> Le dimanche 02 janvier 2011 =E0 23:39 +0100, stefani@seibold.net a =E9=
crit :
> > +
> > +/*
> > + * Create a new destination descriptor for the given IPV4 address =
and port
> > + */
> > +static struct udpcp_dest *new_dest(struct sock *sk, __be32 addr, _=
_be16 port)
> > +{
> > +	struct udpcp_dest *dest;
> > +	struct udpcp_sock *usk =3D udpcp_sk(sk);
> > +
> > +	if (usk->connections >=3D udpcp_max_connections)
> > +		return NULL;
> > +
> > +	dest =3D kzalloc(sizeof(*dest), sk->sk_allocation);
> > +
> > +	if (dest) {
> > +		usk->connections++;
> > +		skb_queue_head_init(&dest->xmit);
> > +		dest->addr =3D addr;
> > +		dest->port =3D port;
> > +		dest->ackmode =3D UDPCP_ACK;
> > +		list_add_tail(&dest->list, &usk->destlist);
> > +	}
> > +
> > +	return dest;
> > +}
> > +
>=20
> Hmm, so 'connections' is increased, never decreased.
>=20
> This seems a fatal flaw in this protocol, since a malicious user can
> easily fill the list with garbage, and block regular communications.

You are right, there is now way to detect which connection is no longer
needed. I have not designed this protocol, so i cannot fix it.=20

But in our environment this will be used together with an firewall
and/or ipsec. In this case it it safe.
