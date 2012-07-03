From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Tue, 3 Jul 2012 11:44:43 +1000
Message-ID: <20120703114443.26e03246debd0652e8d1e92b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__3_Jul_2012_11_44_43_+1000_t3tlV20DXxg=t5iF"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes.berg@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__3_Jul_2012_11_44_43_+1000_t3tlV20DXxg=t5iF
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/mac80211/mlme.c between commit 0030bc586591 ("mac80211: destroy
assoc_data correctly if assoc fails") from the wireless tree and commit
bdcbd8e0e3ff ("mac80211: clean up debugging") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/mac80211/mlme.c
index 0db5d34,e6fe84a..0000000
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@@ -2170,17 -2148,19 +2148,17 @@@ ieee80211_rx_mgmt_assoc_resp(struct iee
  	*bss =3D assoc_data->bss;
 =20
  	if (status_code !=3D WLAN_STATUS_SUCCESS) {
- 		printk(KERN_DEBUG "%s: %pM denied association (code=3D%d)\n",
- 		       sdata->name, mgmt->sa, status_code);
+ 		sdata_info(sdata, "%pM denied association (code=3D%d)\n",
+ 			   mgmt->sa, status_code);
  		ieee80211_destroy_assoc_data(sdata, false);
  	} else {
 -		sdata_info(sdata, "associated\n");
 -
  		if (!ieee80211_assoc_success(sdata, *bss, mgmt, len)) {
  			/* oops -- internal error -- send timeout for now */
 -			ieee80211_destroy_assoc_data(sdata, true);
 -			sta_info_destroy_addr(sdata, mgmt->bssid);
 +			ieee80211_destroy_assoc_data(sdata, false);
  			cfg80211_put_bss(*bss);
  			return RX_MGMT_CFG80211_ASSOC_TIMEOUT;
  		}
- 		printk(KERN_DEBUG "%s: associated\n", sdata->name);
++		sdata_info(sdata, "associated\n");
 =20
  		/*
  		 * destroy assoc_data afterwards, as otherwise an idle

--Signature=_Tue__3_Jul_2012_11_44_43_+1000_t3tlV20DXxg=t5iF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP8k6LAAoJEECxmPOUX5FEzd4QAJ62Dn3pILRBP5uC/07tPQTu
p/NNiwmawJ7TD4yFVYHPe7iMOYQjIG33aRbKwq5hyNguARG9dCURQUClqqWBoHln
9c9NdiLdsieyB906w3V4vZDtXaVwqDsLHCUlbfMXSn8KWFanjeGGrCsJB2PtgFKh
D4UQQJaCXieQIkzAieL3sYV5midiX9+fpaU0eBQjjBrclehgTCw9QRFBlNvi9wov
uSrMACyiChTWzmG25bGRCTBgLKv+5eW27BRDTYiD3bEeDufZA4xz1ED2MRymAcnP
0zfl2MHTYLKdCqOcD1Nkml0PHLpLUMdsui5gykkuat2KqENlLUEn75Iyh7qjmyjl
YbVg58vSN0Vl8+SKR3S8cuEb6ztxpsy1AvEHqRgejcVVkVi7vpoAYyUuYVZNB9Sr
jiSbGVD7HunNQo+PKPAOGtschTpHjEo9BuuIvd8dfFtXDEkGTtEUMCzWXJcERyyd
gGSUEoSCt5AXAEBPIGdCxh7atlsmEhXRgq53A3yejIZ6zGz6/y6ySnwYl/IySFex
Zx8CoDeNeO2UUhmelGzyjApdUP5Kl96izQgFxUCcHFGYTosWz/hEYSi5NQHg7YEX
h0qvU0g4B6KU8nMwP7jnN0Z4866i86q1Bzqcr/RK5RKKAv2mbIVIURRXvMFmO26L
OuxBU3RhCZ+q7ZbK9IcB
=nWND
-----END PGP SIGNATURE-----

--Signature=_Tue__3_Jul_2012_11_44_43_+1000_t3tlV20DXxg=t5iF--
