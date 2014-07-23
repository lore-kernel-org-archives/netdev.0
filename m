From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Wed, 23 Jul 2014 12:00:54 +1000
Message-ID: <20140723120054.7c0e08b3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/J9S=tJ7N1qL3kZRoKJynCb7"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	David Spinadel <david.spinadel@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/J9S=tJ7N1qL3kZRoKJynCb7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/wireless/iwlwifi/mvm/mac80211.c between commit c6a21ff31994
("iwlwifi: mvm: fix merge damage") from the wireless tree and commit
fb98be5e9419 ("iwlwifi: mvm: add unified LMAC scan API") from the
net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/iwlwifi/mvm/mac80211.c
index 98556d03c1ed,2eb6ebee4467..000000000000
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@@ -303,6 -321,16 +321,9 @@@ int iwl_mvm_mac_setup_register(struct i
  		hw->uapsd_max_sp_len =3D IWL_UAPSD_MAX_SP;
  	}
 =20
 -	if (mvm->fw->ucode_capa.flags & IWL_UCODE_TLV_FLAGS_UAPSD_SUPPORT &&
 -	    !iwlwifi_mod_params.uapsd_disable) {
 -		hw->flags |=3D IEEE80211_HW_SUPPORTS_UAPSD;
 -		hw->uapsd_queues =3D IWL_UAPSD_AC_INFO;
 -		hw->uapsd_max_sp_len =3D IWL_UAPSD_MAX_SP;
 -	}
 -
+ 	if (mvm->fw->ucode_capa.api[0] & IWL_UCODE_TLV_API_LMAC_SCAN)
+ 		hw->flags |=3D IEEE80211_SINGLE_HW_SCAN_ON_ALL_BANDS;
+=20
  	hw->sta_data_size =3D sizeof(struct iwl_mvm_sta);
  	hw->vif_data_size =3D sizeof(struct iwl_mvm_vif);
  	hw->chanctx_data_size =3D sizeof(u16);

--Sig_/J9S=tJ7N1qL3kZRoKJynCb7
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJTzxddAAoJEMDTa8Ir7ZwVeTMP/0zDAnFq4PJFpqhSbdTbiJaA
d1PtX/4wujbmQhHdnJsyywrxojVx7h1zZbZURQvcO/ZhYCCmSCY4K1KeeiwOwnEx
cu49s/fXjM2S9+8a7TL4SbkysQgF74yerhm9Kg3CRkgHb8oM2Zg8wyah1jXBKCCr
3Nig5aamlrFsi8VAPCbrfmCzW9QnynSxEmZFPGS/S2bMiirK+Rdy6o/qkNtlC/a7
aNUdPU5UlayGrhP7fiIdQ2KH3RG9xptGliGkUZT1zjFEKC4bzC90yjdCveNUhKYZ
5ww1Z0wA5ZNcjNN9vLCdiBuwr7/LOPjVi7OQ/9PbMq2I3vLWpsMoZ28XlWx9eeed
4MbhD9VoZMb3ZkZGW6rLZhL903ZfRTVpKT20XOAbsx8XZUHou9nP58pGJFXeTpsH
NnSkpW/Z93GQeRLYny6rP55xh4kAuwyGL7IfqvyihyzdHjFQATs5ojKduiriO+5Z
yHbP76kdSx0FaNjckIPLyXsBo4HZJwO3iyhsxLVxqu4qBcA2QKIqFs+zZPkkgnwF
LC1azGjiqYpR/H7eOPGEolbXRuN0hq/H3j0sbMfh+ulrkavPpAyvMW8axewZKOB7
GN2mlksU5yqtNbLYWesR8swtPoCzGjd8+H1W30dxQ9pvfdj2+P55tYZohppDr9If
r2g9EcV5ildgdKBRXJp+
=BRSD
-----END PGP SIGNATURE-----

--Sig_/J9S=tJ7N1qL3kZRoKJynCb7--
