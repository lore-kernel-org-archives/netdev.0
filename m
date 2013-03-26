From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Tue, 26 Mar 2013 11:48:52 +1100
Message-ID: <20130326114852.770f3e14f4b59aa29800e7f7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__26_Mar_2013_11_48_52_+1100_6L665DeZ_WM_m89W"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__26_Mar_2013_11_48_52_+1100_6L665DeZ_WM_m89W
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/mac80211/sta_info.c between commit 27a737ff7cb0 ("mac80211: always
synchronize_net() during station removal") from the wireless tree and
commit 8d1f7ecd2af5 ("mac80211: defer tailroom counter manipulation when
roaming") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/mac80211/sta_info.c
index 238a0cc,3644ad7..0000000
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@@ -794,19 -798,14 +799,21 @@@ int __must_check __sta_info_destroy(str
  	list_del_rcu(&sta->list);
 =20
  	mutex_lock(&local->key_mtx);
 -	for (i =3D 0; i < NUM_DEFAULT_KEYS; i++)
 +	for (i =3D 0; i < NUM_DEFAULT_KEYS; i++) {
- 		__ieee80211_key_free(key_mtx_dereference(local, sta->gtk[i]));
+ 		__ieee80211_key_free(key_mtx_dereference(local, sta->gtk[i]),
+ 				     true);
 -	if (sta->ptk)
 +		have_key =3D true;
 +	}
 +	if (sta->ptk) {
- 		__ieee80211_key_free(key_mtx_dereference(local, sta->ptk));
+ 		__ieee80211_key_free(key_mtx_dereference(local, sta->ptk),
+ 				     true);
 +		have_key =3D true;
 +	}
  	mutex_unlock(&local->key_mtx);
 =20
 +	if (!have_key)
 +		synchronize_net();
 +
  	sta->dead =3D true;
 =20
  	local->num_sta--;

--Signature=_Tue__26_Mar_2013_11_48_52_+1100_6L665DeZ_WM_m89W
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRUPB0AAoJEECxmPOUX5FE+aYP/iDCN0u9SHvJEULCvqb+zekQ
qqSUJdj90rKT4Sa4/PSWE9CtzTdPgAJyDjFid3qgvMF7E4XlOroyxzFmLGUEBZFZ
yBt09RHVbkoOQgzAYKhN9laxQiZR7C+V5JM8hG5ddncL76UvzoqOZjXrHDNeSFmH
XWx6zdVTho02SHHSwJbMSiPOHesBJN0pS+KpxIz64TGv20W/rU1IoATcHt1Hcrza
QOIoDoCtzzFzrhfr8rYinNtIvCIZoCh74gijPv9K5gOM/K0RukTnYGdhkXOE8hHG
/RTMVjirIRVgUBgaiCO4/YDdCW8gPEd73D4EjES60XjMX7KZDNeFGnm2fCpQsoOx
1xQOts0SZWetprbz/5GjsGKMeNQq9YH+f3VUrDYB1fS3NBBuLH3W7dMANHhULkiW
I4u2Dg+QTgEQGRUTEU7IPLcqoEGrMUSMt/Kh2tQx4fb8qsc+pO4YZLKKwtEuXKiw
h6rmlh6bqRHpd0tP4q2Sk1/EeI0rWAPaFAUNsBHRAKDcqZEYbMtUZDgiseJl0TTR
awbJUq8nMwvoHV1ALIfkwx5TcVp4GsQKJP85GFZf8KD8xSdUgv1Xu9kchtHR+dBf
zcw5KtvAETzr9ZyxIpHKgNsUHQlWkm3vk43Db8iFj9DFcYdewF31KF3YhI/OBFHx
80SGRm0yw10ucrqP2NNp
=8Y81
-----END PGP SIGNATURE-----

--Signature=_Tue__26_Mar_2013_11_48_52_+1100_6L665DeZ_WM_m89W--
