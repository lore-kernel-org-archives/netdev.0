From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Wed, 1 Feb 2012 13:39:50 +1100
Message-ID: <20120201133950.ece9e39bba11f943e4724014@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__1_Feb_2012_13_39_50_+1100_o3K7sK3MFzOWeO3n"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:45746 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753237Ab2BACkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jan 2012 21:40:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__1_Feb_2012_13_39_50_+1100_o3K7sK3MFzOWeO3n
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/rtlwifi/rtl8192se/sw.c between commit e404decb0fb0
("drivers/net: Remove unnecessary k.alloc/v.alloc OOM messages") from the
net-next tree and commit f30d7507a811 ("rtlwifi: Convert RT_TRACE macro
to use ##__VA_ARGS__") from the wireless-next tree.

The former removed the code modified by the latter, so I did that (see
below).
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index 36140cc,ca38dd9..0000000
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@@ -186,9 -226,14 +226,11 @@@ static int rtl92s_init_sw_vars(struct i
 =20
  	/* for firmware buf */
  	rtlpriv->rtlhal.pfirmware =3D vzalloc(sizeof(struct rt_firmware));
 -	if (!rtlpriv->rtlhal.pfirmware) {
 -		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 -			 "Can't alloc buffer for fw\n");
 +	if (!rtlpriv->rtlhal.pfirmware)
  		return 1;
 -	}
 =20
+ 	rtlpriv->max_fw_size =3D sizeof(struct rt_firmware);
+=20
  	pr_info("Driver for Realtek RTL8192SE/RTL8191SE\n"
  		"Loading firmware %s\n", rtlpriv->cfg->fw_name);
  	/* request fw */

--Signature=_Wed__1_Feb_2012_13_39_50_+1100_o3K7sK3MFzOWeO3n
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPKKX2AAoJEECxmPOUX5FEj14P/0V6AwPrzUGfAxESJHiEzpji
maZ+61hEXWI9L4skvF1rDyIU0PHyRpzdm6yBxNL3/TdNLIUH/hGc5rsrMr2nonFv
FzmOtnZrbyHrtiVdwU3QI70mBE6zxK+iA20Akt88M8tXu4KLEpLc9D51ih+G22M5
K7JByqFZqEKP/1h3+iunESkMKxK0pKdmNplWsEuzAOl+nDfYinBin0dxvWAlBH+f
zIUzhJBpVRkGHGSk0lUMSEPmLNasY7mzIM9HfUc9uMRNA2iIwASKhUJiLXzUidEu
vrKle9hASokQd03ngmopGIq31hqHYOQaQk+otm19qkdikiQfyg4nQpEgbmaRC8U+
TZPs2AHCOsQL7mmosyYHFt+3sAIl2/3+7LRa/15IJSuGeEPqYtAyyEPaLjVT0oF8
tlA0GDeVgK7jROv8d7rJDwhz1mxeF6os/zXLkfF2D7TpyTher4xi4jk45DoguuSJ
yqh5rgjjqSOcRzVkhJaOAMO1wjNI450YapwgD+eN2yJwUl4D6LjN8OLH27VooiyT
3lOdF3xH78CxtSWnOrazCPLqKFfU8MpK9Ztw2UWSl+OEBbQA3NNm2gp8CKEeZhI4
e4orLlei3VRQlG6KP1ajcQOrrTauZ7o4yLlxlmPvyrrMY2OXDHtyzQsmMd8c38GH
GLdcBcwuBrkrl8BibH5T
=MrdA
-----END PGP SIGNATURE-----

--Signature=_Wed__1_Feb_2012_13_39_50_+1100_o3K7sK3MFzOWeO3n--
