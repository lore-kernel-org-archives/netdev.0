From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless
	stack
Date: Mon, 05 Jan 2009 14:16:19 +0100
Message-ID: <1231161379.3334.14.camel@johannes>
References: <20090104151819.GA6590@basil.nowhere.org>
	 <1231085150.3296.3.camel@johannes>
	 <20090104162826.GT496@one.firstfloor.org>
	 <1231087288.3296.15.camel@johannes>
	 <20090104174339.GX496@one.firstfloor.org>
	 <1231090388.3296.17.camel@johannes>
	 <20090104184136.GY496@one.firstfloor.org>
	 <1231144574.3286.15.camel@johannes>
	 <20090105132141.GO496@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-TUZJM0+lc4BJn2x0ZZ/S"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090105132141.GO496-qrUzlfsMFqo/4alezvVtWx2eb7JE58TQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-TUZJM0+lc4BJn2x0ZZ/S
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-01-05 at 14:21 +0100, Andi Kleen wrote:

> > This statement is incompatible with your patch when you think about the
> > exact definition of truesize and the (unconditional!) adjustments your
> > patch makes.
>=20
> __alloc_skb does=20
>=20
>         size =3D SKB_DATA_ALIGN(size);
>         skb->truesize =3D size + sizeof(struct sk_buff);
>=20
> [ BTW it would be probably better if alloc_skb() just asked
> slab what the truesize is for kmalloc instead of guessing wrong like this=
.
> But that's a different topic]
>=20
> and SKB_DATA_ALIGN is=20
>=20
> #define SKB_DATA_ALIGN(X)       (((X) + (SMP_CACHE_BYTES - 1)) & \
>                                  ~(SMP_CACHE_BYTES - 1))
>=20
> and on my configuration SMP_CACHE_BYTES is 64
>=20
> skb_truesize_check does=20
>=20
>  int len =3D sizeof(struct sk_buff) + skb->len;
>=20
>         if (unlikely((int)skb->truesize < len))
>                 skb_truesize_bug(skb);
>=20
> This means if the change is less than the 64byte cache alignment=20
> (or more commonly 128 bytes on GENERIC_CPU distro kernels)
> it won't be reported. To my knowledge header adjustments are usually
> smaller and that is what pskb_expand_head() is usually used for.

Ah, indeed, I thought I remembered that truesize had to match exactly,
but obviously that wasn't done either. We should experiment with that
though, and let pskb_expand_head() adjust things.

> I didn't use any monitoring with this. No tcpdump, no wireless
> sniffer tools or anything. It happened all the time during
> normal operation.

You did have a monitor interface up though, didn't you? If nothing
actually used those skbs then it's likely that the warning didn't result
in any corruption at all.

johannes

--=-TUZJM0+lc4BJn2x0ZZ/S
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJYgghAAoJEKVg1VMiehFYDxgP/iazIvan411+Tql/zQ/pdzI2
0lOHqwOTM217fYdAXDzbmBYNosG8xy37VfjmjQjI35BDVL/bJaybZcSNvrK/DvV7
7wW9k2AeOhKzmvPM+w+cyn7jmso+WC4ww+toPeZtbvmRwsWAFa8Ow3NwAGwNUXzS
47b+A8bn68iZDsVh8VnxeZAQ8/DWahNjhHRoub2TfoD6IA9+nSD6Ahe1Sgccfukq
DSI2JiBfgznJroag3w3NIvOXtn/+y6hUJ1vEsFMjEauGqQhK7RpbxK8SWvgqjQ6C
IaboEFHgYAURwW7YR3GksxHIQ+XN0J6eErXfIYabNENYtanhmmCkpUfzh8KkW1sj
0NsBy1NtQD6jGPYpuNmbiYI8JFW7bL7hzZvo44WW7aYKQhqm8J5CuuW90gAlz0Oc
4RoOBHqPiEfyHxmAhYY75vk3ujC97OSfdsjzMYngHT9/A2JPvkgejk9v2N7Oscks
8CkZh0AbhJcz2tutU72gYXlVAQ5Vv2CqbF2d1nWK1CebJOUOsoKFMO+Oc9TEpopz
r6kXIccSWUnVjkHjc3X0qm+z6b6Npx4f6QRMI/bmFFcG3xoBEDVpj+F81NItqrW0
JZjoyDXCuTMSN2F5NKTEdF06oJqrrBb1hWuJymuUhdVcAfzqE3nIxpJHbD09dhji
zQEvSEu0TnGJERZGljOg
=Q1MN
-----END PGP SIGNATURE-----

--=-TUZJM0+lc4BJn2x0ZZ/S--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
