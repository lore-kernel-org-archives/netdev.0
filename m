From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Tue, 10 Apr 2012 11:32:09 +1000
Message-ID: <20120410113209.1fb17bdc05e5995a4821cf46@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__10_Apr_2012_11_32_09_+1000_SdudSJy2oqGhwwA4"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Meenakshi Venkataraman <meenakshi.venkataraman@intel.com>,
	"Wey-Yi Guy" <wey-yi.w.guy@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__10_Apr_2012_11_32_09_+1000_SdudSJy2oqGhwwA4
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/iwlwifi/iwl-testmode.c between commit d33e152e1edd
("iwlwifi: Stop using NLA_PUT*()") from the net-next tree and commit
a42506eb27aa ("iwlwifi: move ucode_type from shared to op_mode") from the
wireless-next tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/iwlwifi/iwl-testmode.c
index a54e20e,d65dac8..0000000
--- a/drivers/net/wireless/iwlwifi/iwl-testmode.c
+++ b/drivers/net/wireless/iwlwifi/iwl-testmode.c
@@@ -609,10 -605,9 +612,10 @@@ static int iwl_testmode_driver(struct i
  			inst_size =3D img->sec[IWL_UCODE_SECTION_INST].len;
  			data_size =3D img->sec[IWL_UCODE_SECTION_DATA].len;
  		}
- 		if (nla_put_u32(skb, IWL_TM_ATTR_FW_TYPE, priv->shrd->ucode_type) ||
 -		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_TYPE, priv->cur_ucode);
 -		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_INST_SIZE, inst_size);
 -		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_DATA_SIZE, data_size);
++		if (nla_put_u32(skb, IWL_TM_ATTR_FW_TYPE, priv->cur_ucode) ||
 +		    nla_put_u32(skb, IWL_TM_ATTR_FW_INST_SIZE, inst_size) ||
 +		    nla_put_u32(skb, IWL_TM_ATTR_FW_DATA_SIZE, data_size))
 +			goto nla_put_failure;
  		status =3D cfg80211_testmode_reply(skb);
  		if (status < 0)
  			IWL_ERR(priv, "Error sending msg : %d\n", status);

--Signature=_Tue__10_Apr_2012_11_32_09_+1000_SdudSJy2oqGhwwA4
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPg42ZAAoJEECxmPOUX5FEgt4P/0WiIo1LuvhyCLpfZ6xxDujQ
Y/a/SWb8W0KEapXzuSok21N5JW42dtWyxD8YIzbSVEZdWGPUWgOFjvJ64HF+Gm0O
5TiO7a391gUzFH12vFjc6yaHAWiMUKs0oiMF8m8m6Sclyse1m4uj9orxqfA1ztRo
uSUAJaxAehRHBylBTx/sHchIzcGGW27TuSOf5VUKh6kjTBZsC9Bl2yTmNu7n8FdM
08Quk4nEKjMb+PWqRcrHs8EEB94/8N50afVEfSbxOel02uBvwTfaoUpSMFtioHn6
X4b5j0r7bfvfbhEfoMXLZqwlfwGW4Mq9j0oK7nMGARIjDnrJF3vIT2vdsWnBWWXN
v9snTjZreQTNQXMrTBoeIzUYca2bCvbWn4nc+oG9VsHU1kxA6UoSim5Y6TSb/Z3p
rCLqxTZ3N0/wAh1TSpbHzk5w6jtRGbx+BSMkjFpcHoKsplkMO3ot8EKrB00IPzR+
I+PgHMbzVZCyS+yIhJ3dBsRj4Re3a4Ffho+wzVYzq78iQC0JMJtfA5wbe7qX2Yla
qnn3XtmfX8outQTjE8+413K+QC6j/GUOh2FBrsaiWYZv92tVGjozIB+xqcwtfd8Z
DEpGjQOku137vU6aC2+/4lejwS2qhdBpKYws4DNYuUBqabNUXN/UomG96pVtNr16
XgnphierwkKIx/k7sSsx
=EIvQ
-----END PGP SIGNATURE-----

--Signature=_Tue__10_Apr_2012_11_32_09_+1000_SdudSJy2oqGhwwA4--
