From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH bluetooth-next 10/10] ipv6: add ipv6_addr_prefix_copy
Date: Wed, 9 Dec 2015 14:28:38 -1000
Message-ID: <64AE99C3-E5EB-47D8-9B0A-FA5B35E93CB2@holtmann.org>
References: <1449697591-15991-1-git-send-email-alex.aring@gmail.com> <1449697591-15991-11-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449697591-15991-11-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> This patch adds a static inline function ipv6_addr_prefix_copy which
> copies a ipv6 address prefix(argument pfx) into the ipv6 address pref=
ix.
> The prefix len is given by plen as bits. This function mainly based o=
n
> ipv6_addr_prefix which copies one address prefix from address into a =
new
> ipv6 address destination and zero all other address bits.
>=20
> The difference is that ipv6_addr_prefix_copy don't get a prefix from =
an
> ipv6 address, it sets a prefix to an ipv6 address with keeping other
> address bits. The use case is for context based address compression
> inside 6LoWPAN IPHC header which keeping ipv6 prefixes inside a conte=
xt
> table to lookup address-bits without sending them.
>=20
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
> Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> Acked-by: =C5=81ukasz Duda <lukasz.duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org>
> Acked-by: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
> Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> include/net/ipv6.h | 15 +++++++++++++++
> 1 file changed, 15 insertions(+)
>=20
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 9a5c9f0..6570f37 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -401,6 +401,21 @@ static inline void ipv6_addr_prefix(struct in6_a=
ddr *pfx,
> 		pfx->s6_addr[o] =3D addr->s6_addr[o] & (0xff00 >> b);
> }
>=20
> +static inline void ipv6_addr_prefix_copy(struct in6_addr *addr,
> +					 const struct in6_addr *pfx,
> +					 int plen)
> +{
> +	/* caller must guarantee 0 <=3D plen <=3D 128 */
> +	int o =3D plen >> 3,
> +	    b =3D plen & 0x7;
> +
> +	memcpy(addr->s6_addr, pfx, o);
> +	if (b !=3D 0) {
> +		addr->s6_addr[o] &=3D ~(0xff00 >> b);
> +		addr->s6_addr[o] |=3D (pfx->s6_addr[o] & (0xff00 >> b));
> +	}
> +}
> +
> static inline void __ipv6_addr_set_half(__be32 *addr,
> 					__be32 wh, __be32 wl)
> {

if there are no objections, I would like to take this change through th=
e bluetooth-next tree.

Regards

Marcel
