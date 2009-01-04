From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless
	stack
Date: Sun, 04 Jan 2009 17:41:28 +0100
Message-ID: <1231087288.3296.15.camel@johannes>
References: <20090104151819.GA6590@basil.nowhere.org>
	 <1231085150.3296.3.camel@johannes>
	 <20090104162826.GT496@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-kQQ1zFKPdjYQTgHRUUEm"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090104162826.GT496-qrUzlfsMFqo/4alezvVtWx2eb7JE58TQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-kQQ1zFKPdjYQTgHRUUEm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-01-04 at 17:28 +0100, Andi Kleen wrote:
> > Thanks, but I'll need to look at this in more detail, we need to make
> > sure that we orphan the skb before=20
>=20
> What do you mean with orphaning the skb?=20

Well, touching truesize is absolutely not allowed while the skb is
charged to a socket. This is what causes the truesize warning. The thing
we need to do is figure out is why the skb has a wrong truesize.

> etc. And then, we need to check
> > whether it makes sense to do this in pskb_expand_head().
>=20
> Well whatever you do this short term patch is needed, there's no=20
> reason to delay it.

Given that we've had this problem for a very long time now I think
there's no reason to rush a workaround now. I realise that we already
have a workaround like this in the tx path which we added because I
thought the tx path was the problem, but it still doesn't make much
sense to work around it at all spots until we know why it is required.

I think this patch similarly just papers over the problem with
pskb_expand_head(). I haven't looked through all the code yet, but if
anything then I think pskb_expand_head() should fix up truesize
afterwards, and we should audit all other callers too. Similar problems
exist in net/core/pktgen.c, drivers/net/wireless/libertas/rx.c,
net/ipv4/netfilter.c and many more, though those seem to not run into
trouble. Only a few users adjust truesize.

Any proper fix should also verify that the skb isn't charged to a socket
while it's being reallocated.

johannes

--=-kQQ1zFKPdjYQTgHRUUEm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJYOa0AAoJEKVg1VMiehFYzn0P/iOiDuJjuf47+4QcJS/mQ4gO
KQuStEKHlbeX3DVmN7xHgj34Yk0EJG9kFClElQXyVw1ewJW1CbT9AylmPF2TesSK
+TnSdMjZRhujVBgtxLD3i9QdzyBfco4y5t4AUXVCYP7v5Ae7fY9uOMI50doIBegj
rKpZiTUSv6fBqz7LLpy23tjVP5R6Yxs9+jYFv0Ezc8WsQvG7e7gx2daTtsGwJY0f
tuhcnI1R7Zd+JpfA107JG/YIll4XHLQfN6xL+hhtpXj2/yOcgmmt7kCDzU2KKpGk
lfvqSIfij7zdbCvMPWhG5W6BqVL0whon5OVCjApqTYyVaGMwEW00IhoXFHC8rECq
+JlooyyqEaouhJIO93qTL4mIgauJC9aMqbIARaPtzOSdLDAK1cgoMumHNuhlFTcB
AHGtyJpNOlpltyL6GsfOuJn8j6pFhgLYolbO2JHF1zskAkH1KKiHo4/Spyt6qyrA
ikT0WFqDre/jvTXy1IUjWb4dQ2UwNVsD+708QjGJD1HM/5UsuaaAMpOL3jDWwsby
0e0wO0FERg2QBJiLD6nUA/Ihrh76O2qZAirM45D5vuqwFkhHwW6pnpjJhAZRqldp
qfC6P38FXLnqtmUSXIJGT0EnDta0MywJT3Bq2JvFizBbyLP7GdlqO9FtX1eEcv4o
Fe+RGdA2KpqgDkwDl7BC
=EFy2
-----END PGP SIGNATURE-----

--=-kQQ1zFKPdjYQTgHRUUEm--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
