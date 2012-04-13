From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Fri, 13 Apr 2012 12:30:55 +1000
Message-ID: <20120413123055.8d25d96b3d3c055b726b8519@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__13_Apr_2012_12_30_55_+1000_wu5wiKKbJkMT8jEM"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Meenakshi Venkataraman <meenakshi.venkataraman@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__13_Apr_2012_12_30_55_+1000_wu5wiKKbJkMT8jEM
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/iwlwifi/iwl-testmode.c between commit d33e152e1edd
("iwlwifi: Stop using NLA_PUT*()") from the net-next tree and commits
11483b5c2296 ("iwlwifi: move eeprom into priv") and a42506eb27aa
("iwlwifi: move ucode_type from shared to op_mode") from the
wireless-next tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/iwlwifi/iwl-testmode.c
index a54e20e,c8e89ca..0000000
--- a/drivers/net/wireless/iwlwifi/iwl-testmode.c
+++ b/drivers/net/wireless/iwlwifi/iwl-testmode.c
@@@ -540,12 -539,11 +543,12 @@@ static int iwl_testmode_driver(struct i
  				IWL_ERR(priv, "Memory allocation fail\n");
  				return -ENOMEM;
  			}
 -			NLA_PUT_U32(skb, IWL_TM_ATTR_COMMAND,
 -				IWL_TM_CMD_DEV2APP_EEPROM_RSP);
 -			NLA_PUT(skb, IWL_TM_ATTR_EEPROM,
 -				cfg(priv)->base_params->eeprom_size,
 -				priv->eeprom);
 +			if (nla_put_u32(skb, IWL_TM_ATTR_COMMAND,
 +					IWL_TM_CMD_DEV2APP_EEPROM_RSP) ||
 +			    nla_put(skb, IWL_TM_ATTR_EEPROM,
 +				    cfg(priv)->base_params->eeprom_size,
- 				    priv->shrd->eeprom))
++				    priv->eeprom))
 +				goto nla_put_failure;
  			status =3D cfg80211_testmode_reply(skb);
  			if (status < 0)
  				IWL_ERR(priv, "Error sending msg : %d\n",
@@@ -609,10 -605,9 +612,10 @@@
  			inst_size =3D img->sec[IWL_UCODE_SECTION_INST].len;
  			data_size =3D img->sec[IWL_UCODE_SECTION_DATA].len;
  		}
- 		if (nla_put_u32(skb, IWL_TM_ATTR_FW_TYPE, priv->shrd->ucode_type) ||
 -		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_TYPE, priv->cur_ucode);
 -		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_INST_SIZE, inst_size);
 -		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_DATA_SIZE, data_size);
++		if (nla_put_u32(skb, IWL_TM_ATTR_FW_TYPE, priv->ucode_type) ||
 +		    nla_put_u32(skb, IWL_TM_ATTR_FW_INST_SIZE, inst_size) ||
 +		    nla_put_u32(skb, IWL_TM_ATTR_FW_DATA_SIZE, data_size))
 +			goto nla_put_failure;
  		status =3D cfg80211_testmode_reply(skb);
  		if (status < 0)
  			IWL_ERR(priv, "Error sending msg : %d\n", status);

--Signature=_Fri__13_Apr_2012_12_30_55_+1000_wu5wiKKbJkMT8jEM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPh4/fAAoJEECxmPOUX5FEUvQQAJFr7VzYhyvKZv4Q2eIAtcpB
sfHnVIbJuih4+XLrjaX2p7zUNHP45C3IWRY+x/9QFSiPZ8AZGMtMopFbL9GF/h+m
6YkolhWdcMYqi8C10E57IGxii1zRFMJzTm6zr4Rpw91CuYc3/AWz5mVV67uCvGqC
hr1C2Dcsyo4z5ttnSNBKmQRF0nyP1/Kcwdll1iDbC3H8r1pDHpBUn22hL930Y9qM
5MuG5kOETsOJWz+4Kfi1D7+qqg317kIUA/nEgHGf7FgCGdkxZFmqpMAi9zWlKLRr
GbcEtDY2P3LpqurBxqZf0JYkYQZyLbKFTbEZDPu0apjNh5XEAu3QQAfWo2guTEDX
KWQ3HnqN5hlF+7jxWRe4NF7RqbH5fxPPk/rptQ1aZwOMnWq9qcsScj+ke0YuaDU+
srg13z5hvhS7/4JIH4PFede98jqL0JiqnE98G70KVuE2wkdMxq8sUPCFRo+pOtLl
bgdfsg56SrH22u3Dpgu/WyBW+oZ2m//91xR/c3Y7EBz11lx/mKWkNKdpdm3dVMr1
GicMRJsetMTDM/xftXocEul5A++eaSOzqi7SKAFL3myPuWXtwzlOlShX92citx0L
Aja83VKfqCVpgSRxyxqhFEwERWmyi01BYrg7W000oKja+2AMP0YK9ejVxgCSkHGp
TwbMUuxoBW1iGYYZ8iMy
=YV3d
-----END PGP SIGNATURE-----

--Signature=_Fri__13_Apr_2012_12_30_55_+1000_wu5wiKKbJkMT8jEM--
