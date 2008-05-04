From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 10:47:27 +0200
Message-ID: <1209890847.6210.51.camel@johannes.berg>
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
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-mLloipbxbIHC8cUG2Yz4"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080504031652.GA30993-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-mLloipbxbIHC8cUG2Yz4
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-05-04 at 11:16 +0800, Herbert Xu wrote:
> On Sun, May 04, 2008 at 04:22:20AM +0200, Johannes Berg wrote:
> >
> > Yes, wireless always needs at least 24 bytes, but more likely 34
> > (encryption+QoS). However, I just increased LL_MAX_HEADER to 54 and tha=
t
> > doesn't seem to have helped.
>=20
> How did you test it?

I stuck a WARN_ON((nhead || ntail) && skb->sk) into pskb_expand_head
(which never triggered except from mac80211). And mac80211 has code that
calculates the required header length and only calls pskb_expand_head()
from that place when it needs more header space (or the skb is cloned. I
should repeat this test)

> > What's wrong with, instead, doing skb_orphan() and then
> > pskb_expand_head()? That seems to have the same effect.
>=20
> If you packet sticks around for long enough then this skews the
> accounting.  In any case, thinking too much about optimising this
> part is a waste of time because we should be thinking about having
> enough head room in the packet so that we don't have to expand
> it in the first place except for the odd packet.

Very true. How about tail length? :)

johannes

--=-mLloipbxbIHC8cUG2Yz4
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB14HqVg1VMiehFYAQJauQ//eoYwc+fNheBaFa+NjMnIu7ulVvBoQCBf
DjEPLVEJ1zC5vl+8KL2/1u2rgYuRsfPGnEEFW3mpuPt+9VKWAqt7e4RHtoLU8wZz
jEQwBVoIkmBJ1RhidgqLcGIgEXTM25LERBx8h0BfLrx+2Nqc56zhcVO0H6h0cbDU
DgmW8bocrtHlxqKe7fFceFoi80WwFDrXeq2N2KnJHUXMsAeqhe/yK7QpqZPZUFWV
hPBe7vpCzMEhuznDIktxDsild3rNho3x6JBXwnPAbqt7BrFiXFcQliv2XtwU2hLT
NoVwurGJptiu8/+Q9yKlfqesLM9r32vPas/gY2OhwtZhjZz332fv5/2YOrTNQDqI
AqCjfKec5ayCipY2xdUGHdJyP11nr0pTb1aJqhK+zmBc91zHjti2se9DqXky+UxT
sTB04nhPCBcZIld9wy27Ll7D42yxobB6zIjzN1UdM1APpYV7oXbNDKNG3qJZx5AC
Cr9wLrmmH4VsYApg4Hf+YVU3JT5XaCGYdrqktQFUHsrN5TsahIsVT3qYOWRmXb0D
4si3yTFBveGuI9dvWB5yooOzJ7AFQX9eW/EpuvR1pZoRUX/SM2htKgtipf3qes75
1WHcmBfcH/j60L0o5Pc5gG02T53hUouvYQoZ6KtYpT2IVq+8bWbhRPULt+oZJbua
27ikVPrIq6Y=
=hmQl
-----END PGP SIGNATURE-----

--=-mLloipbxbIHC8cUG2Yz4--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
