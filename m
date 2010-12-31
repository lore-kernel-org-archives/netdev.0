From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 11:29:13 +0100
Message-ID: <1293791353.5193.1.camel@wall-e>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
	 <1293790501.2973.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293790501.2973.33.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, den 31.12.2010, 11:15 +0100 schrieb Eric Dumazet:
> Le vendredi 31 d=E9cembre 2010 =E0 10:29 +0100, stefani@seibold.net a
> =E9crit :
> > +				spin_lock_irqsave(&spinlock, flags);
> > +				udpcp_stat.txMsgs++;
> > +				spin_unlock_irqrestore(&spinlock, flags);
>=20
> This is really ugly for different reasons :
>=20
> 1) Naming a lock, even static "spinlock" is ugly.

Agree...

> 2) Using a lock for stats is not necessary, and
>    disabling hard irqs is not necessary either (spinlock_bh() would b=
e
> more than enough)
>  =20
>    At a very minimum, you should use atomic_t so that no lock is need=
ed
>=20
> 3) Network stack widely use MIB per_cpu counters.
>  As you use UDP, you could take a look at UDP_INC_STATS_BH()/
> UDP_INC_STATS_USER() implementation for an example.
>=20

I will have look at this and revamp it.
