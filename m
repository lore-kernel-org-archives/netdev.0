From: jhf@rivenstone.net (Joseph Fannin)
Subject: 2.6 sis900 (and tlan?) multicast bug
Date: Mon, 26 Jan 2004 15:42:15 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040126204215.GA25578@rivenstone.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

"Craig A. Huegen" <huegen@pentics.com> wrote:
> In the same vein as:
> http://seclists.org/lists/linux-kernel/2003/Oct/5794.html

> ...there is a bug in the SiS900 driver in 2.6.1 which prevents multicast
> MAC filtering from working properly.  This breaks IPv6.

    I'm seeing this problem too.  My sis900 interface can't get an
IPv6 address unless promiscious or allmulti mode is set, since it
doesn't get responses on ip6-allrouters.

    Please note that I am not subscribed to netdev, so a CC on any
responses would be appreciated.

> Patch attached (same one as from the 2.4 post from Oct 28) that made
> IPv6 work for me again.

    From the original post, referring to the change this reverts:

>> This will not work for bit_nr larger than 16 and hence the failure.
>> Reverting to use set_bit causes multicast to be handled properly.

> --- linux/drivers/net/sis900.c.old	2004-01-17 03:56:53.893211412 -0600
> +++ linux/drivers/net/sis900.c	2004-01-17 03:57:02.785567615 -0600
> @@ -2091,9 +2091,8 @@
>  		rx_mode =3D RFAAB;
>  		for (i =3D 0, mclist =3D net_dev->mc_list; mclist && i < net_dev->mc_c=
ount;
>  		     i++, mclist =3D mclist->next) {
> -			unsigned int bit_nr =3D
> -				sis900_mcast_bitnr(mclist->dmi_addr, revision);
> -			mc_filter[bit_nr >> 4] |=3D (1 << bit_nr);
> +			set_bit(sis900_mcast_bitnr(mclist->dmi_addr, revision),
> +				mc_filter);
>  		}
>  	}

    This fix didn't go into 2.4 either, so presumably something is wrong
with it (perhaps we're moving away from set_bit)?  I am over my head
here really, but I don't want to just set allmulti mode and forget
about this bug.

    I'm seeing the same behavior with my Thunderlan interfaces and
the tlan driver -- setting allmulti or promiscious mode fixes it
(while other boxes here with 3c509 and 3c556 cards work fine with the
same configuration.)  I wonder, now that USAGI is in the stable
kernel, how many multicast bugs like this will turn up?

    If anyone has any ideas where in tlan.c to begin looking, I'd be
glad to hear them; I'm not completely technically inept :-).

--=20
Joseph Fannin
jhf@rivenstone.net

"I think I said something eloquent, like 'Fuck.'" -- Rusty Russell.

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAFXunWv4KsgKfSVgRApUkAJsF9kzJLOVI3Ffsk0ejZ5WjK+Y4+ACfTT2U
PxZBCeOiGIkRbsJw09YuybI=
=w67/
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--
