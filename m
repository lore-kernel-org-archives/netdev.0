From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 23:38:21 +0200
Message-ID: <42B9DA4D.5090103@cosmosbay.com>
References: <1119458226.6918.142.camel@localhost.localdomain>	<200506221801.j5MI11xS021866@guinness.s2io.com>	<20050622180654.GX14251@wotan.suse.de> <20050622.132241.21929037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: ak@suse.de, leonid.grossman@neterion.com, hadi@cyberus.ca,
        becker@scyld.com, rick.jones2@hp.com, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050622.132241.21929037.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :

>=20
> 2) As shown above, it gives you compute time which can be used to
>    schedule the prefetch.  This nearly makes RX replenishment free.
>    Instead of having the CPU spin on a cache miss when we run
>    eth_type_trans() during those cycles, we do useful work.
>=20
> I'm going to play around with these ideas in the tg3 driver.
> Obvious patch below.


Then maybe we could also play with prefetchw() in the case the incoming f=
rame
is small enough to be copied to a new skb.

drivers/net/tg3.c

	copy_skb =3D dev_alloc_skb(len + 2);
	if (copy_skb =3D=3D NULL)
		goto drop_it_no_recycle;
+	prefetchw(copy_skb->data);

	copy_skb->dev =3D tp->dev;
	skb_reserve(copy_skb, 2);
	skb_put(copy_skb, len);
