From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH -next] gre: return more precise errno value when adding
 tunnel fails
Date: Wed, 12 Feb 2014 22:33:32 +0000
Message-ID: <1392244412.15615.25.camel@deadeye.wl.decadent.org.uk>
References: <1392197311-9676-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+Mm2fbhxbHTRXT3qzPZW"
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52861 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752638AbaBLWdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:33:44 -0500
In-Reply-To: <1392197311-9676-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+Mm2fbhxbHTRXT3qzPZW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-02-12 at 10:28 +0100, Florian Westphal wrote:
> Currently this always returns ENOBUFS, because the return value of
> __ip_tunnel_create is discarded.
>=20
> A more common failure is a duplicate name (EEXIST).  Propagate the real
> error code so userspace can display a more meaningful error message.
>=20
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/ipv4/ip_tunnel.c | 15 ++++++++++-----
>  1 file changed, 10 insertions(+), 5 deletions(-)
>=20
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 90ff957..ef43356 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -393,7 +393,7 @@ static struct ip_tunnel *ip_tunnel_create(struct net =
*net,
>  	fbt =3D netdev_priv(itn->fb_tunnel_dev);
>  	dev =3D __ip_tunnel_create(net, itn->fb_tunnel_dev->rtnl_link_ops, parm=
s);
>  	if (IS_ERR(dev))
> -		return NULL;
> +		return (void *) dev;
[...]

This should be written as ERR_CAST(dev).

Ben.

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-+Mm2fbhxbHTRXT3qzPZW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvv2vOe/yOyVhhEJAQrXEQ/+OaOnu8ZbMjIUsxDKt64fj8YjSD09/Nqz
20Mz4cqbrd4BYtl89arVWrknOtRbajzkFiZk5GC2sAVVz5PePK+Vn7pwiz7tNN0N
RXFCm2mLFIkqkh1izn737wdzeP+b/9yqBs+zEyxLPyGcGbTV9Y53iM4ElrZCtJTH
HUAv5u3EnrdwWDGzpkJ5YLhrOPdekQPS3olGdz3zENL50JLqDhiUZxHH9HMkkLvi
xYNynmwrdwXD85lZGi+ObMw/E0dq1oI8y7HR3bufCfd48gFCk42b5biDF/wdRdo3
9E1juFH+glgnl14bf/UkcKfEs9LZCjGIuMf7lt4A6jj9Z1obKJKCkz6Lxf94dblc
ZXM7utkX4STt1glVLLMbALq35kXw7UjBIeAQQ1uR2cYbZYV3+8sj9hAelPZoC8bF
B2YFNQ3SNKEJRRuFgF0kSShD7er/M1CboBy2rMAUlz5NaDFVrRhntaMMft5gEE02
QwSg1RpX6IN1J5ZMbOa4JMuOED8CcyQEMsG9nxK3EwO5SPNub6FYcp+jgzt7aCW9
nbgYVnae4N52TDZlSaO/UbXEDD5qveQuLCk9wW0uwTCt0u0iJvyOP6uhErGorkGX
drR4RINCYJyr+Af23NEQx2AyfCFPiOM6u4EN99XqOMXwU/FzmIVZjNqpfhhna+oL
orUQW2Ct9nM=
=Uncp
-----END PGP SIGNATURE-----

--=-+Mm2fbhxbHTRXT3qzPZW--
