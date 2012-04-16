From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Mon, 16 Apr 2012 12:48:51 +1000
Message-ID: <20120416124851.a581885c87bbe627b11e50ff@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__16_Apr_2012_12_48_51_+1000_ZAr9oA.Ha+ja2lN9"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Johannes Berg <johannes.berg@intel.com>,
	"Wey-Yi Guy" <wey-yi.w.guy@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__16_Apr_2012_12_48_51_+1000_ZAr9oA.Ha+ja2lN9
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/iwlwifi/iwl-testmode.c between commit d33e152e1edd
("iwlwifi: Stop using NLA_PUT*()") from the net-next tree and commit
11483b5c2296 ("iwlwifi: move eeprom into priv") from the wireless-next
tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/iwlwifi/iwl-testmode.c
index f31a062,c8e89ca..0000000
--- a/drivers/net/wireless/iwlwifi/iwl-testmode.c
+++ b/drivers/net/wireless/iwlwifi/iwl-testmode.c
@@@ -543,12 -539,11 +543,12 @@@ static int iwl_testmode_driver(struct i
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

--Signature=_Mon__16_Apr_2012_12_48_51_+1000_ZAr9oA.Ha+ja2lN9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPi4iTAAoJEECxmPOUX5FEwZEP/3V/pNhINVAZJnCtsv8+kOrh
dqoS8nimZw4EHcGm4icRxjk5X9F+nQHSoKUPFtR5Clc+8TJAkkVvg+utZRUuvyQh
lsEpcY9rYgzhbvkr/H3DnMu5107XmjROlRpYObr/KQIf9L1OCHcWtj9pwCH9Z/J2
IxiB18wwQ+0sn7H5GnDeYdmIf+szHIGUr3qRr8dzMdv6FOxlu9a2sP6uuuMuc81d
ryPAn8T0shMB2zL9f4j68T/mLZrXUCliba0luAcr4Zgoma2yVE08Sq6vlo805dim
P2q7M3kuj0iShVjK3fmqmRwe7382lzNSpI0qzHBqSsOjjPgmHEWNaGNhoIRJpumF
jE7o/nEYZS7/k13QXz7Cr7otF6X04JV+h/LgUhhsIib8bLhIX+IEODXxQ9wt5RSa
JSQ4l2rFN3lw2GrmCXuC/q3pKosgAWxbgFbn8Sb8d/CWRCSwhQTONbHyOjTeU1LW
06qyNx9Jb8WGrb4dT7eb2xmhcI2jyvGrai2iaCn5EANP1DFxSVzpDGx7/0K8Cxs2
114MPneLHnmyE475Lz4vOJC9hyoYLwaY7XuuwzF5u0NLpNye+ddGq9lfMjtSYrY1
8u59zZlFJoIptExVG+arr1OvevsoqVMns1XG6+h39buOHKRWO6wZV5nLcyujZpRw
cuK/7TGu0VEzEFBCwyIq
=ygvT
-----END PGP SIGNATURE-----

--Signature=_Mon__16_Apr_2012_12_48_51_+1000_ZAr9oA.Ha+ja2lN9--
