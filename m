From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 04:08:36 +0200
Message-ID: <1209866916.6210.39.camel@johannes.berg>
References: <1209760731.3608.17.camel@johannes.berg>
	 <20080502.163334.148944203.davem@davemloft.net>
	 <1209815533.3987.21.camel@johannes.berg>
	 <20080503.180300.10562559.davem@davemloft.net>
	 <1209865354.6210.23.camel@johannes.berg>
	 <20080504020203.GA30514@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-GuQHjY1piMMh7lxTGlRN"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080504020203.GA30514-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-GuQHjY1piMMh7lxTGlRN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-05-04 at 10:02 +0800, Herbert Xu wrote:
> On Sun, May 04, 2008 at 03:42:34AM +0200, Johannes Berg wrote:
> >
> > I'm still not sure about the dependencies between LL_MAX_HEADER,
> > dev->hard_header_len and similar. Why, for example, does ipip set it to
> > LL_MAX_HEADER + sizeof(struct iphdr)? Because it doesn't know better
> > since the packets it creates could be routed anywhere?
>=20
> The difference between LL_MAX_HEADER and hard_header_len is that
> the former is a system-wide hint of how big the header can be
> and the latter is a device-specific value.
>=20
> In other words, we use the former when we don't know where we
> create a packet since we don't know where it'll end up.  As such
> we allocate a generous amount of header space so that hopefully
> nobody will have to expand the header later.  However, it would
> be OK for someone to expand it but obviously it this happened
> for the majority of your traffic then you've done something wrong
> since expanding it wastes CPU resources by copying the data.
>=20
> The value of hard_header_len on the other hand is used for two
> purposes at least.  First of all it is a hint of how much free
> header space there should be in a packet before it goes into a
> device (but don't rely on it).  More importantly it's the length
> of the hardware header in the packet.  The definition of the
> hardware header varies with each type of device.

Ok, thanks for the explanation. The latter probably means that I cannot
use hard_header_len since mac80211 really needs devices to show up as
ethernet devices. However, it wouldn't really help anyway if I cannot
rely on it being available.

So, what is mac80211 supposed to do? It needs up to 54 bytes of
available headroom (for an encrypted mesh packet which currently can't
really happen, but anyway) yet it cannot pskb_expand_head() either.
Cloning each packet seems even more expensive, and just like skb_orphan
subverts the purpose of the socket accounting.

johannes

--=-GuQHjY1piMMh7lxTGlRN
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB0ao6Vg1VMiehFYAQLB3hAAqi7ELI0q6fXWP+V4Q2UEoI0fs/lgILJJ
vUj5H9GTPunylhPneT+1spPVThOPEx7lyJF+vW9KEr65rOQfkbuNhdSBDscR98pp
HwhTbq5iag7LqgiDBDsI7RHd8bmkKOIgI3lRP6Yc5VeT8p8gZ84XA0yjwl6qudV/
0aldF+H+4ztCbeBLoYQAcBWUqbUTQatlojrMIgiG8jD2ns91hSZo0Nyv2+2sQVYa
EqCZeUpqHSiXCYOhX7Ff7lRl5fLdrZdlrSUv3n5VQcebW3E6cF9jdtJT5LO6K82i
CSYP7GE3ybTAWgdUaf2hxCBgkaj4IuemQjaiw2kMhT4Zh/qIADhNr7VplDf8law0
DLno8g3Gh17nC/xMUDX/PDLOA40C/oz1PkU45u7Y+rTe1Kfa4/Y6yGULeafjUz3A
+QEH4GgXDYbRRqek05OWEu21sAU9MqTx24sC5QRWcLhfwnDwJdQjzWG+fcZHh88k
O0lzIGjP1LZTrT7Q14Vua1gtmqQEG0wlBD74t5oKxC4HfwOHEyWJ6LaU5juDmkYo
RO0ytPFp7iSFnQPoCv4pe+u3fKv9T0i1d94b9kkqKA8JQIpHZFwQpyb7JPO152rF
mv55YRhroi/K7pzRYemOzkI7ssJSi3AqWygua3hsyfopd37YHKHweYeMHSNBTEdm
Cg3nIdEnxdU=
=rRJK
-----END PGP SIGNATURE-----

--=-GuQHjY1piMMh7lxTGlRN--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
