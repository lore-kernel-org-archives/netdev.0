From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Sat, 01 Jan 2011 22:28:45 +0100
Message-ID: <1293917325.28510.1.camel@wall-e>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
	 <1293794758.2973.49.camel@edumazet-laptop>
	 <1293796805.2973.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293796805.2973.62.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, den 31.12.2010, 13:00 +0100 schrieb Eric Dumazet:
> Le vendredi 31 d=E9cembre 2010 =E0 12:25 +0100, Eric Dumazet a =E9cri=
t :
> > Le vendredi 31 d=E9cembre 2010 =E0 10:29 +0100, stefani@seibold.net=
 a
> > =E9crit :
> > > +		if (!list_empty(&usk->destlist)) {
> > > +			state->sk =3D (struct sock *)usk;
> > > +			state->dest =3D list_first_entry(&usk->destlist,
> > > +					struct udpcp_dest, list);
> > > +			sock_hold(state->sk);
> > > +
> > > +			if (atomic_read(&state->sk->sk_refcnt) !=3D 1) {
> > > +				spin_unlock_irqrestore(&spinlock, flags);
> > > +				return state;
> > > +			}
> > > +			atomic_dec(&state->sk->sk_refcnt);
> > > +		}
> > > +
> >=20
> > I am trying to understand what you are doing here.
> >=20
> > It seems racy to me.
> >=20
> > Apparently, what you want is to take a reference only if actual
> > sk_refcnt is not zero.
> >=20
> > I suggest using atomic_inc_notzero(&state->sk->sk_refcnt) to avoid =
the
> > race in atomic_dec().
> >=20
> >=20
>=20
> Before you ask why its racy, this is because UDP sockets are RCU
> protected, and RCU lookups depend on sk_refcnt being zero or not.
>=20
> Doing an sk_refcnt increment/decrement opens a race window for the
> concurrent lookups.
>=20

I still revamped the whole /proc/net/udpcp thing and hope it is now rac=
e
free.
