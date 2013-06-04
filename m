From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Tue, 4 Jun 2013 12:33:47 +1000
Message-ID: <20130604123347.df8639ba69cb914069c80fd6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__4_Jun_2013_12_33_47_+1000_rB8FBrbILt6R11I+"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sujith Manoharan <c_manoha@qca.qualcomm.com>,
	Jingoo Han <jg1.han@samsung.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__4_Jun_2013_12_33_47_+1000_rB8FBrbILt6R11I+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/ath/ath9k/debug.c between commit 27d7f47756f4 ("net:
wireless: replace strict_strtoul() with kstrtoul()") from the net-next
tree and commit 6e4d291eec82 ("ath9k: Print ANI statistics in debugfs")
from the wireless-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/ath/ath9k/debug.c
index 51cc0fa,7852f6e..0000000
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@@ -200,12 -244,15 +244,15 @@@ static ssize_t write_file_ani(struct fi
  		return -EFAULT;
 =20
  	buf[len] =3D '\0';
- 	if (kstrtoul(buf, 0, &disable_ani))
 -	if (strict_strtoul(buf, 0, &ani))
++	if (kstrtoul(buf, 0, &ani))
  		return -EINVAL;
 =20
- 	common->disable_ani =3D !!disable_ani;
+ 	if (ani < 0 || ani > 1)
+ 		return -EINVAL;
+=20
+ 	common->disable_ani =3D !ani;
 =20
- 	if (disable_ani) {
+ 	if (common->disable_ani) {
  		clear_bit(SC_OP_ANI_RUN, &sc->sc_flags);
  		ath_stop_ani(sc);
  	} else {

--Signature=_Tue__4_Jun_2013_12_33_47_+1000_rB8FBrbILt6R11I+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRrVIQAAoJEECxmPOUX5FEeigP/3In1LFW5LdD2NkUqZC3SfFR
+6jikG1NNh31wHO7oY5TMg72W8kCDG8xk76p9UcJjuLiML62rd873aFI1D4bdeo/
H+qt49ncMruzWP406X1DMf5QBfhZTYTofppQN5HB+agM2mhCmMJOcmJRg1qau/Ch
apBLapN7ATtKydRWeBokKf0j/EiF7awnoReYYgx8ha8DPDf6PV/GxVZSC2kY/mCe
70nGtFje/S7TwG/qG+OrTQZzy0AofnNbK4Mz4BEAc3wqxsi/QwR3lwI2vHR2Pju9
ZhdR9Fhh+7RYtb1ZOAcuyOac1CYFmxZBhNfn7CGRsKgbiLtzVg+TO+nQtgmzBu8Q
gvAuFTM7VIlt1MEnmsYuIuJXTfqaJITJP4NWc6FcwizctCVNSick672eHOPnTEx2
oOlEEj/SOy9U9oFfEG2K2d9TD5TGcSl4soMKOZr0fd5It60aMromodi3n1tR7dmD
aFaLZlEf3/WHihImiBbbnRK7Ci147Byt0ObZN5K5pLfR8KEhQx8cLQ/MTJJCMZIt
+Y+mqHTD2+CPsYFS+/fLKXi3dvMGWug2snVk05cTauSgnWWNZCPIdxk/1KXgPzgV
tQQZZY2jQVMaf7U0EuQbx6HqHoKhTwZOHs5JY1sZQH3JGiTqTbDcoqFHJkIO4WnK
TX63/IE/XF3/6bqm9DY9
=IhqN
-----END PGP SIGNATURE-----

--Signature=_Tue__4_Jun_2013_12_33_47_+1000_rB8FBrbILt6R11I+--
