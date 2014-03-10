From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: phy: fix uninitalized WOL parameters in
 phy_ethtool_get_wol
Date: Mon, 10 Mar 2014 02:51:33 +0000
Message-ID: <1394419893.15968.88.camel@deadeye.wl.decadent.org.uk>
References: <1394413270-7169-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0098268422476007236=="
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1394413270-7169-1-git-send-email-sebastian.hesselbarth@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============0098268422476007236==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-M2iU1wxOH00rdU/TUKFB"


--=-M2iU1wxOH00rdU/TUKFB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-10 at 02:01 +0100, Sebastian Hesselbarth wrote:
> phy_ethtool_get_wol is a helper to get current WOL settings from
> a phy device. When using this helper on a PHY without .get_wol
> callback, struct ethtool_wolinfo is never set-up correctly and
> may contain misleading information about WOL status.
>=20
> To fix this, always zero relevant fields of struct ethtool_wolinfo
> regardless of .get_wol callback availability.

I think it's the caller's responsibility to zero out struct
ethtool_wolinfo.  That is what ethtool_get_wol() does.

Maybe you could split ethtool_get_wol() like we did
ethtool_get_settings(), to support in-kernel invocation of ETHTOOL_GWOL?

Ben.

> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Cc: David Miller <davem@davemloft.net>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/phy/phy.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 19c9eca0ef26..62a7cd401e1c 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -1092,6 +1092,7 @@ EXPORT_SYMBOL(phy_ethtool_set_wol);
> =20
>  void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolin=
fo *wol)
>  {
> +	wol->supported =3D wol->wolopts =3D 0;
>  	if (phydev->drv->get_wol)
>  		phydev->drv->get_wol(phydev, wol);
>  }

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-M2iU1wxOH00rdU/TUKFB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUx0otee/yOyVhhEJAQrXcg/+MTq4nMnpSS2NdDvwc4Gg5u0eDaU4q96k
CaGXoGCyBNTf6wCXhpsmP1gxmVkwdQ/ZsIj+S8Gvrpf3OFlLMn8GXce6R11U4Y+0
NT2V6H1YGls4jpryTAdm95ZnbFtBldNfeOGSkZ5dJHoehKrtnFTu4bB0jhFM50+p
PoWdOEfw8dbJsdKYE2SuRG17sSDpFptLDWjFyn2GTMBsai4WNoMFNoG6+pfp3Q2l
wDErIcasn5zck7YmG+/vbtnb6IH4a6gre8ah0OBka+5vhlCzmgMudtYSpW0S1ACZ
m/X3iq1r7Kh4HhInCW7inwEpXncAUxBbI9im3vPFuLjTEJqqwgXelzmPVOPvRewg
Y3VXXSmu5GZY4A6RQthu8derZrRvRLiM/ry6uKWQdUs1DwPKpl2loFnP/GCptiEr
bezv/P4LaKZHfm0FhQshwBAp0tT/hG9kJKocmbjl6cKdVdDRdP7Y8RiG9Fg7o7+C
IYW3k+sq7u15vTextN+irjwVgZnYfgt9fAMGNnJNd/RaMf1LCc6jIWkkV5ZwEUyZ
p/Ae/jFnBQZLTRJjtrCcFt3YTH8gR2nGQSDQZe0xiFsDCPlecNDiHLKYlDDVGBU/
aKp4g5+nlcgxhQf5nXLf/SDPVfZKq/BA4HEKkSra6dU6MzGRv636hpEKi8q/u1yZ
VDU8U5wXvLc=
=1+Ux
-----END PGP SIGNATURE-----

--=-M2iU1wxOH00rdU/TUKFB--


--===============0098268422476007236==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============0098268422476007236==--
