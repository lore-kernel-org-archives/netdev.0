From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH net-next v2 10/13] r8152: support IPv6
Date: Sun, 09 Mar 2014 19:47:55 +0000
Message-ID: <1394394475.15968.25.camel@deadeye.wl.decadent.org.uk>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
	 <1394002168-3193-1-git-send-email-hayeswang@realtek.com>
	 <1394002168-3193-11-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-u6mNg2t3ZiHbmTT/OYJH"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394002168-3193-11-git-send-email-hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-u6mNg2t3ZiHbmTT/OYJH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-05 at 14:49 +0800, Hayes Wang wrote:
> Support hw IPv6 checksum for TCP and UDP packets.
>=20
> Note that the hw has the limitation of the range of the transport
> offset. Besides, the TCP Pseudo Header of the IPv6 TSO of the hw
> bases on the Microsoft document which excludes the packet length.
>=20
> Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
> ---
>  drivers/net/usb/r8152.c | 107 ++++++++++++++++++++++++++++++++++++++++++=
++++--
>  1 file changed, 104 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 8f6d0f8..8e208f30 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
[...]
> +static int msdn_giant_send_check(struct sk_buff *skb)
> +{
> +	const struct ipv6hdr *ipv6h;
> +	struct tcphdr *th;
> +
> +	ipv6h =3D ipv6_hdr(skb);
> +	th =3D tcp_hdr(skb);
> +
> +	th->check =3D 0;
> +	th->check =3D ~tcp_v6_check(0, &ipv6h->saddr, &ipv6h->daddr, 0);
[...]

I think you need to call skb_cow_head() before editing the header here.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-u6mNg2t3ZiHbmTT/OYJH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxzFa+e/yOyVhhEJAQo6sBAA0lYYFOvhPfsJhWdjXkuP3am7mqbyqOGO
s9sVsBPYg6fDBQzGmMYB2zn+gIi7wPNQGX0/UQPQePHbcxmCxkTw7Q+CarCzeYrP
arodhyaUOOdlwJMsz7VGN03j7NIx3Gu4QH9z/gqCw6JUAraREYJlenfgdVa5uGz9
sNsQpxjhjtYPI6YfWlh/QLHfFvG8AJL8F4pOWINz0LXaoEr2QvuLGHwd4pvN+fn/
Ts2sYuCnC2DMtU0nTzKmkIUKXEPj5WigwE1dKynvS585eMfu+T+2908oeoDY71WU
7iO8G0ZEINOQspqEhYzzVc/AmhD5qwVLBFHYX5D54FYOKsJ6mcoYFugpV3c5ZOXq
5u0eRE1HVA9icTj/Eqp5nz9VEmPnRpd6OhqQB6XPn9S20jGH53b4fxj0DoYiWL/4
6KeLg1z1uL4Dd5Aa461Ud/72QFCpkNEw8JCqOUdiXZ48QH0FIDvcjOiDHuC+GLKv
/Q5vBskmzRW75enH4TGjrKhUWT3IV+FGErhckobRpz/4lsNPG/bXazhZWJ9/WLrE
sF1+gdFDaf2cYUQ9llK2qLYlAOc5D5BLDMvBqVFxAAMkkUpXjqrYr1q/jfd2ac+J
ichjvfg52a2TzTXMi3P1LW01QL8xfUu3QDyBUc13+Y1TABLRcVmPllD53t0I2L5N
C91FwTDQcUA=
=WjG0
-----END PGP SIGNATURE-----

--=-u6mNg2t3ZiHbmTT/OYJH--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
