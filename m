From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Tue, 24 Apr 2012 12:48:03 +1000
Message-ID: <20120424124803.f4dc75ea96a875c3f35db615@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__24_Apr_2012_12_48_03_+1000_RYx7J0P8wXf47REW"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	"Wey-Yi Guy" <wey-yi.w.guy@intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__24_Apr_2012_12_48_03_+1000_RYx7J0P8wXf47REW
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/iwlwifi/iwl-testmode.c between commit d33e152e1edd
("iwlwifi: Stop using NLA_PUT*()") from the net-next tree and commit
2152268ff911 ("iwlwifi: op_mode holds its pointer to the config") from
the wireless-next tree.

I was hoping that we were done with these ... :-(

I fixed it up (see below) and can carry the fix as necessary.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/iwlwifi/iwl-testmode.c
index bb27509,a6b16aa..0000000
--- a/drivers/net/wireless/iwlwifi/iwl-testmode.c
+++ b/drivers/net/wireless/iwlwifi/iwl-testmode.c
@@@ -543,12 -539,11 +543,12 @@@ static int iwl_testmode_driver(struct i
  				IWL_ERR(priv, "Memory allocation fail\n");
  				return -ENOMEM;
  			}
 -			NLA_PUT_U32(skb, IWL_TM_ATTR_COMMAND,
 -				IWL_TM_CMD_DEV2APP_EEPROM_RSP);
 -			NLA_PUT(skb, IWL_TM_ATTR_EEPROM,
 -				priv->cfg->base_params->eeprom_size,
 -				priv->eeprom);
 +			if (nla_put_u32(skb, IWL_TM_ATTR_COMMAND,
 +					IWL_TM_CMD_DEV2APP_EEPROM_RSP) ||
 +			    nla_put(skb, IWL_TM_ATTR_EEPROM,
- 				    cfg(priv)->base_params->eeprom_size,
++				    priv->cfg->base_params->eeprom_size,
 +				    priv->eeprom))
 +				goto nla_put_failure;
  			status =3D cfg80211_testmode_reply(skb);
  			if (status < 0)
  				IWL_ERR(priv, "Error sending msg : %d\n",

--Signature=_Tue__24_Apr_2012_12_48_03_+1000_RYx7J0P8wXf47REW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPlhRjAAoJEECxmPOUX5FEI5MP/0+2Wqq8cAzuPhh882ISOHkG
Vv8nSfAKY7giDI5RAG7TwvzdqGybV6RGgbr/ljeSrfFJBgYynmAitw+iYOUU6nb/
GjjDol0J3u3xNLpCeEfLEB/lwEkmlcPme6klAAg4E+Ni5gfKBeejYBdidgWNfKRX
9ZgfBMZboYKbM6sclQxNkP6MA1behIDC1XoeTPrzOuwv1Fs/DT2n78NKcbzREUPw
tmUJIBHx2NW/ihuX0SldZdFFRSSidSkMWPaO3Ovh4c61tmcpHTacGlzClN81qqJD
C6r10myMGLKfK8Rg4YstlGYkLjM+zZ6Pwns66v09nNndCsn0b+ZnK2QZYGQ+UamO
aa5t5zVWaInWFB2c2WEqoIXvmEms+F0d1/AGypROFsH7kXZk9Vy30QvI/SuGJ46y
GxTSCUmPkNPvj+7VtiOo6fI1YtCjxJeeAvMV/ifOAoNLs0dHc4EkfuoxC9FeOKSK
Y0dycOQYzhMtlpXrk9wmOdZ5ZOe3bMnXHNthcIh5YLtslBP7QchbvrqvmDhsIGiQ
xMrqzmnPBTscyFSAB8W0zt09KUAZSClKyIlbWkDoAn1cmPoL/RywMRZyodDkAuWE
lGrUzTx9cO7jNvhQ1B7EEhDx63mfkcXWVhMyGwW+UprxuiZ8+IRWUDe/EQK0a7eO
ZojfOxeoovg2gmzoc8I/
=5L06
-----END PGP SIGNATURE-----

--Signature=_Tue__24_Apr_2012_12_48_03_+1000_RYx7J0P8wXf47REW--
