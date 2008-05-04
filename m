From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 11:14:49 +0200
Message-ID: <1209892489.6210.56.camel@johannes.berg>
References: <1209760731.3608.17.camel@johannes.berg>
	 <20080502.163334.148944203.davem@davemloft.net>
	 <1209815533.3987.21.camel@johannes.berg>
	 <20080503.180300.10562559.davem@davemloft.net>
	 <1209865354.6210.23.camel@johannes.berg>
	 <20080504020203.GA30514@gondor.apana.org.au>
	 <1209866916.6210.39.camel@johannes.berg>
	 <20080504021213.GA30660@gondor.apana.org.au>
	 <1209867740.6210.46.camel@johannes.berg>
	 <20080504031652.GA30993@gondor.apana.org.au>
	 <1209890847.6210.51.camel@johannes.berg>
	 (sfid-20080504_104709_030839_DDDB35A5)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-BeyIogCxkM0n0O04BgNI"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209890847.6210.51.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (sfid-20080504_104709_030839_DDDB35A5)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-BeyIogCxkM0n0O04BgNI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-05-04 at 10:47 +0200, Johannes Berg wrote:
> On Sun, 2008-05-04 at 11:16 +0800, Herbert Xu wrote:
> > On Sun, May 04, 2008 at 04:22:20AM +0200, Johannes Berg wrote:
> > >
> > > Yes, wireless always needs at least 24 bytes, but more likely 34
> > > (encryption+QoS). However, I just increased LL_MAX_HEADER to 54 and t=
hat
> > > doesn't seem to have helped.
> >=20
> > How did you test it?
>=20
> I stuck a WARN_ON((nhead || ntail) && skb->sk) into pskb_expand_head
> (which never triggered except from mac80211). And mac80211 has code that
> calculates the required header length and only calls pskb_expand_head()
> from that place when it needs more header space (or the skb is cloned. I
> should repeat this test)

I just re-did the test, and I definitely need 29 more bytes on, for
example, the IPv6 autodiscovery packets and ICMP packets generated with
ping(8). Some of them even need additional tailroom.

johannes

--=-BeyIogCxkM0n0O04BgNI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB1+h6Vg1VMiehFYAQLaXA/+KX923/3gIL6wqS1qhvM7NZJEsljFhsYe
Z8B6kuHFSit3biUAv9taZpmWZozcQiMP78BShlTesuhhnrRDxTBxrbUi25OMv5FF
GBODHUnY63aibZg/rRN30eo1mtty/DoEhf3bDpE4uho1faM/HFh4Ckfxzd4lzigt
JuaaHncDFP6G7GA4Egp1Hzhvi924495ddDpLKrYm+uVyKw07qTmp1hfNctmpX5kl
hdD7Iha4pcVCCZkeRsevgm3pZaEP7WckL4ndSaSnkIVV/87D3/P5BSXSof95NQBL
Y+tSbJIVevXkDCAi9gjjBEjTYl8DKegf7ewc7KVMZGjZxP8ClmRp8X56sPeJTeNk
Enfg2Q00trueTe+yB1tcDVPDABGHV87ATRIB9zNzwVyoFzEyuGbzHBd/x5h7Eir9
5GzbwFInrim7KZdJD3PDDxAXzkC99373BOe5z1uGk+NXV46BKoZ6UC8H1zvNpxb2
2cuMDCmDlBfha/r/tkKNcRq4ZwX2qfqV7E4xJ+3ni7n7fg2sqnt3iJvjBKwUJpFa
0SRhDRVcRW4g8jgehp0sdy4oYSOfQ8bXiXNqi7W6twwKYzolu/SjnUtKfs+uBCoU
dIknFfEtG/Ntu+jhMlHqG/+TjGrq3KBwO9zam51j7x4ub6r/wwM71zaK1vftd1yn
kju0HNn6akw=
=OFj/
-----END PGP SIGNATURE-----

--=-BeyIogCxkM0n0O04BgNI--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
