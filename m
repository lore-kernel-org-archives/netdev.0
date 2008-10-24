From: Alex Samad <alex@samad.com.au>
Subject: Re: kernel oops when system under network stress
Date: Fri, 24 Oct 2008 13:09:22 +1100
Message-ID: <20081024020922.GA21547@samad.com.au>
References: <20081016030416.GA5551@samad.com.au> <20081015.215536.242281148.davem@davemloft.net> <20081016050810.GA8240@samad.com.au> <20081016064142.GA5064@gondor.apana.org.au> <20081016070934.GA10150@samad.com.au> <20081016091009.GA5794@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dDRMvlgZJXvWKvBx"
Cc: David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081016091009.GA5794@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Bugger, didn't see this replay, will get on it=20

alex

On Thu, Oct 16, 2008 at 05:10:09PM +0800, Herbert Xu wrote:
> On Thu, Oct 16, 2008 at 06:09:34PM +1100, Alex Samad wrote:
> >
> > just about, within a 5-10 min window
>=20
> Great.  Please apply this patch and let me know what it prints
> out (if anything).
>=20
> Thanks,
> --=20
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection=
_sock.c
> index 16d43f2..72af09d 100644
> --- a/net/ipv6/inet6_connection_sock.c
> +++ b/net/ipv6/inet6_connection_sock.c
> @@ -233,6 +233,13 @@ int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
>  	/* Restore final destination back after routing done */
>  	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
> =20
> +	if (WARN_ON(skb_is_gso(skb) && skb->ip_summed !=3D CHECKSUM_PARTIAL)) {
> +		printk("%s: %d %d %d 0x%x 0x%x 0x%lx", skb->dst->dev->name,
> +		       skb->ip_summed, skb_shinfo(skb)->gso_size, skb->len,
> +		       skb_shinfo(skb)->gso_type, sk->sk_route_caps,
> +		       skb->dst->dev->features);
> +	}
> +
>  	return ip6_xmit(sk, skb, &fl, np->opt, 0);
>  }
> =20
>=20

--=20
"The Legislature makes the laws, and the Executive interprets the laws."

	- George W. Bush

--dDRMvlgZJXvWKvBx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkkBLkkACgkQkZz88chpJ2OzrgCg7Yq4BQjoYbqaogikM1vgbVbx
o+kAn1vV9p2D/M2PbZfLxHiWO8esInRs
=ro5X
-----END PGP SIGNATURE-----

--dDRMvlgZJXvWKvBx--
