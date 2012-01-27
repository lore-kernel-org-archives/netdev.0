From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-01-27
Date: Fri, 27 Jan 2012 15:10:23 -0500
Message-ID: <20120127201023.GC2510@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41925 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674Ab2A0UQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:16:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit b49ba04a3a0382e7314d990707c21094c410425a

Dave,

Here are a couple of "one-liner" fixes intended for 3.3.

A mac80211 fix from Eliad Peller fixes a regression from an earlier
patche that accidentally removed a necessary line of code.  The other
one from Eliad adds an overlooked assignment necessary for proper
management of some state information.  Finally, the fix from Johannes
moves an unlock to include an additional operation within the critical
section.

Pleae let me know if there are problems!

Thanks,

John

---

The following changes since commit 9018e93948c6f8f95fbcc9fa05f6c403d6adb406:

  net: explicitly add jump_label.h header to sock.h (2012-01-26 17:13:26 -0=
500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git master

Eliad Peller (2):
      mac80211: update oper_channel on ibss join
      mac80211: set bss_conf.idle when vif is connected

Johannes Berg (1):
      iwlwifi: fix PCI-E transport "inta" race

 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c |    4 ++--
 net/mac80211/ibss.c                              |    1 +
 net/mac80211/iface.c                             |    1 +
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c b/drivers/net=
/wireless/iwlwifi/iwl-trans-pcie-rx.c
index 752493f..65d1f05 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
@@ -972,11 +972,11 @@ void iwl_irq_tasklet(struct iwl_trans *trans)
 	}
 #endif
=20
-	spin_unlock_irqrestore(&trans->shrd->lock, flags);
-
 	/* saved interrupt in inta variable now we can reset trans_pcie->inta */
 	trans_pcie->inta =3D 0;
=20
+	spin_unlock_irqrestore(&trans->shrd->lock, flags);
+
 	/* Now service all interrupt bits discovered above. */
 	if (inta & CSR_INT_BIT_HW_ERR) {
 		IWL_ERR(trans, "Hardware error detected.  Restarting.\n");
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index b3d76b7..a464396 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -106,6 +106,7 @@ static void __ieee80211_sta_join_ibss(struct ieee80211_=
sub_if_data *sdata,
=20
 	sdata->drop_unencrypted =3D capability & WLAN_CAPABILITY_PRIVACY ? 1 : 0;
=20
+	local->oper_channel =3D chan;
 	channel_type =3D ifibss->channel_type;
 	if (channel_type > NL80211_CHAN_HT20 &&
 	    !cfg80211_can_beacon_sec_chan(local->hw.wiphy, chan, channel_type))
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index e47768c..01a21c2 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1314,6 +1314,7 @@ u32 __ieee80211_recalc_idle(struct ieee80211_local *l=
ocal)
 			continue;
 		}
 		/* count everything else */
+		sdata->vif.bss_conf.idle =3D false;
 		count++;
 	}
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPIwSuAAoJEJctW/TcYTgGFd0P/AsF8ClttEp6UKmWw/OAaK6O
QvV173K+6pdr76gdRb6au5e+VptkdECY1DrE6S9jBQXS+XP5ba7+6DMXVlf2zeFY
R1wJTOb7Ur6pCZW8idd0T+StAP/VWx39FfN09IQ6rb7kW9LFUYCSwn7aEqUXNhA8
Cxf7mAG2CE2R2NxnOmy8JbBiGIrjDeLcnFdZ8Cf7esprftJaNrzab1COW/gKyEbl
uSxJueGs+3qrKcBU7ElOkLgKS9KaJbnaDOsuvR3EBg4ghuVz4TxUmMftGICtO0I+
P/Y5wj2eRURQHYgv+xAXcQn7Z3t5oUjQQ02kAQcBn03Cf81YM7xLj7IihquYGdde
by+OYTlCd9SxAUNDAq6KNzFtGaMUZzHkYqDYydfGb63V+kuXZ695yDGjhuSAkc9i
W8ZcMiKZbgulnvBN2b8SNfYzUVEJoCN+/ZDamZb0cZeRL5IceqhZ3ns3cm7tCB0g
32IdF3aeFT6NmSdzn7RQtyon6zF43yugLOlbow97nFyIO0MVMUU/SqOLXeRvliOE
iozqb+ZEX+zzPGr8iEiQdw5NhurPH/DAv88WlEjsz6v/OY21hE+eK1FmpLnR3uCC
yORmvEDgMR4hnbkSw9922MOn5EtxVYnQToliKhcTm0LF92wcw/4CRLvn/oWawkZS
bIA0yGYPck4TFhmZx6/p
=Vb+7
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--
