From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Fri, 23 May 2014 13:45:55 +1000
Message-ID: <20140523134555.1ea341db@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ZGlYi+g=il30/yl50uO7ued"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/ZGlYi+g=il30/yl50uO7ued
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/wireless/iwlwifi/mvm/mac80211.c between commit 7bacc782270f
("iwlwifi: mvm: disable beacon filtering") from the wireless tree and
commit 73e5f2c5d762 ("iwlwifi: remove IWL_UCODE_TLV_FLAGS_BF_UPDATED
flag") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/iwlwifi/mvm/mac80211.c
index 8735ef1f44ae,97c3deae6552..000000000000
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@@ -826,9 -825,8 +825,8 @@@ static int iwl_mvm_mac_add_interface(st
  	if (ret)
  		goto out_remove_mac;
 =20
 -	if (!mvm->bf_allowed_vif &&
 +	if (!mvm->bf_allowed_vif && false &&
- 	    vif->type =3D=3D NL80211_IFTYPE_STATION && !vif->p2p &&
- 	    mvm->fw->ucode_capa.flags & IWL_UCODE_TLV_FLAGS_BF_UPDATED){
+ 	    vif->type =3D=3D NL80211_IFTYPE_STATION && !vif->p2p) {
  		mvm->bf_allowed_vif =3D mvmvif;
  		vif->driver_flags |=3D IEEE80211_VIF_BEACON_FILTER |
  				     IEEE80211_VIF_SUPPORTS_CQM_RSSI;

--Sig_/ZGlYi+g=il30/yl50uO7ued
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTfsR3AAoJEMDTa8Ir7ZwViCEP/0Yob9vxseJ4uDZtm0KeLkwx
K6BlH60z+KZGMS8Ja2uUD6pRxg3EQ/EY41pckpYqMsfq3jdmRRDE/BJxmslsfGDr
RswBd47K/DNH1dLxsDX09AX3pxb1yEsGD9YAUFFjrx58g9LWQqVAkURV46PZE1tT
qQYtKuABw1mM7i1+vtqIVpOCVF2fJFcxyvf8iZAWkuWmihjlT95QVY8kmuX2UTsa
6TpSNZpof4BjLcZctZer8lXWStQSvgegdkU80yIwPtz7DL8d0yMZc4lm5Mk+eN32
BFMZmktiNZsw+gag1oK70VoKsgWVMxNh4jhhcVhE04V3z++xrc9HylzE1eZLF9jP
v+z5pIsLyrCCSnLVM5HwVmnQMVFL2ALxDr3GTnOOjpFI1J/xQcT0+AzqC7CrjW8J
hQAw7Dhtj7cmR2mCElYK0DarHGR8F8LeHjQ7vPr5GIZKHSUNM8/J1p1HvLXnIj7H
VKoX62hPkcZEzhxlfilAFPdQBhaD2nqcNiP3tfrLHmoPjUNaVaHnEdEhABxAZPbJ
Q6A9bkNYUyOohZmKxRf6+8Ig9h6lt1KzwWN7dw02ibhSFFG8kZtNP1q0X37ENfEJ
j9jl/b8Xn5uXGHEmD1POs0IETmjwyXLGrfCseOqBkAlIHLt+THlw+dwSj7WL5zxO
hBDImYZvMC70HmaXvLt1
=i4qk
-----END PGP SIGNATURE-----

--Sig_/ZGlYi+g=il30/yl50uO7ued--
