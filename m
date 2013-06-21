From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the arm-soc tree with the net-next tree
Date: Fri, 21 Jun 2013 15:49:25 +1000
Message-ID: <20130621154925.13c957ee77c5c62e540d7cfc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__21_Jun_2013_15_49_25_+1000_5pD4MS9fbneFeAPh"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mugunthan V N <mugunthanvnm@ti.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Benoit Cousson <benoit.cousson@linaro.org>
To: Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:36587 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935593Ab3FUFth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 01:49:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__21_Jun_2013_15_49_25_+1000_5pD4MS9fbneFeAPh
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the arm-soc tree got a conflict in
arch/arm/boot/dts/am335x-evmsk.dts between commit f6655d697b85 ("ARM:
dts: AM33XX: Add CPSW phy_id device tree data to am335x-evmsk") from the
net-next tree and commit 94a924ca61f0 ("ARM: dts: AM33XX: Add pinmux
configuration for CPSW to EVMsk") from the arm-soc tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arm/boot/dts/am335x-evmsk.dts
index 4297899,9e00eef..0000000
--- a/arch/arm/boot/dts/am335x-evmsk.dts
+++ b/arch/arm/boot/dts/am335x-evmsk.dts
@@@ -249,12 -381,14 +381,24 @@@
  	};
  };
 =20
 +&cpsw_emac0 {
 +	phy_id =3D <&davinci_mdio>, <0>;
 +	phy-mode =3D "rgmii-txid";
 +};
 +
 +&cpsw_emac1 {
 +	phy_id =3D <&davinci_mdio>, <1>;
 +	phy-mode =3D "rgmii-txid";
 +};
++
+ &mac {
+ 	pinctrl-names =3D "default", "sleep";
+ 	pinctrl-0 =3D <&cpsw_default>;
+ 	pinctrl-1 =3D <&cpsw_sleep>;
+ };
+=20
+ &davinci_mdio {
+ 	pinctrl-names =3D "default", "sleep";
+ 	pinctrl-0 =3D <&davinci_mdio_default>;
+ 	pinctrl-1 =3D <&davinci_mdio_sleep>;
+ };

--Signature=_Fri__21_Jun_2013_15_49_25_+1000_5pD4MS9fbneFeAPh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRw+lpAAoJEECxmPOUX5FEpmkP/2XaJ9LaFK3yYKXBCIqVU67G
zNA2tpXHXIi7O0pTqvmXh/vEm6g0iDRZHY7E8dBMoCXIiGVoCnkWUKRCRv3rtww7
zxfMt/bBVDNajhEljBopSTqMfo6yN9a/r9THIIASU9gvf3fv4zfV+d94JkbgJe2T
evIWnnl5bU93bPabS/hCZIJ/b2Jt2nVk5uIPK1S7RPxrZJZxGieSp6TrYRErjhk8
7+u37jxkc/qeaGCJEVowfHSYID4w67hRH74hGib8KpP79hLvvYJK4jSpiCgzDs+2
NDSpjao5W/SbVmuzElpP4nfKCraNxp+yRBOzL9AaY/rxajLo6c2rJhBOtHLbYE6q
S9cu7TTQiItTHybrZjViIHFdpK9f0XX3OCg76UD+6GXJ90Zk3wYt+wje4n36+1zi
s7MY6kemEAM7k2/HCUrM13c1RoEflxq1x7pMKUpV6BV8wTQ5RAnSH58OYig/MT9I
PuZcVXaEC0GajJhvZtWTghXMXxbFqiE8h1PZ94qHWNqgZpymtFlgPpru1U5uGuA/
ITZbrgb0KMa8jH34B0Ke0tBYoGMfkQ/HLqf86sJQSyZ+CbEjImbtox/1Ro+MrAk2
W4ozGSdtxgj+ekqcZjxbclGEJsAi4mHj2AHpumnAE6UEf5C+YxOToCXX9X+WjQXp
jNfItZbjFQJSPKcbFPc9
=FWzo
-----END PGP SIGNATURE-----

--Signature=_Fri__21_Jun_2013_15_49_25_+1000_5pD4MS9fbneFeAPh--
