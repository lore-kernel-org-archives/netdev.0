From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-02-15
Date: Wed, 15 Feb 2012 14:21:06 -0500
Message-ID: <20120215192106.GI4379@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 33b5d30cd8b200024d55ac5830c9efde1102ef4c

Dave,

Here are two more fixes intended for 3.3.  One changes the non-error
return code for a routine in rtlwifi -- it had been masking an error
condition that could lead to a divide by zero.  The other moves a
routine inside of a locked critical section to avoid a "BUG: rwlock bad
magic".

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3013dc0cceb9baaf25d5624034eeaa259bf99004:

  3c59x: shorten timer period for slave devices (2012-02-14 16:28:23 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Mohammed Shafi Shajakhan (1):
      mac80211: Fix a rwlock bad magic bug

Simon Graham (1):
      rtlwifi: Modify rtl_pci_init to return 0 on success

 drivers/net/wireless/rtlwifi/pci.c |    4 ++--
 net/mac80211/main.c                |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlw=
ifi/pci.c
index 39e0907..9245d88 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1501,7 +1501,7 @@ static int rtl_pci_init(struct ieee80211_hw *hw, stru=
ct pci_dev *pdev)
 		return err;
 	}
=20
-	return 1;
+	return 0;
 }
=20
 static int rtl_pci_start(struct ieee80211_hw *hw)
@@ -1870,7 +1870,7 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 	}
=20
 	/* Init PCI sw */
-	err =3D !rtl_pci_init(hw, pdev);
+	err =3D rtl_pci_init(hw, pdev);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 ("Failed to init PCI.\n"));
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 0a0d94a..b142bd4 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -910,6 +910,8 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 		wiphy_debug(local->hw.wiphy, "Failed to initialize wep: %d\n",
 			    result);
=20
+	ieee80211_led_init(local);
+
 	rtnl_lock();
=20
 	result =3D ieee80211_init_rate_ctrl_alg(local,
@@ -931,8 +933,6 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
=20
 	rtnl_unlock();
=20
-	ieee80211_led_init(local);
-
 	local->network_latency_notifier.notifier_call =3D
 		ieee80211_max_network_latency;
 	result =3D pm_qos_add_notifier(PM_QOS_NETWORK_LATENCY,
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPPAWiAAoJEJctW/TcYTgGuXMP/RwrggZXacj6oA5OeYAd9B6I
7g65j857BXlhHCDwOcgJGIXEzYtJkGRuqVumqUurHeEyXQfJAti6Y9ggOTSE9bGd
kJ781QxP3bR8VixiFK2Ceg4p2iJQAumdYqGUEqe8kV74/tPHi/gyIYee7W8usmy3
iRZ4pyxEC0w4aInzXaECXQX9mOreYWlEiIss7WfPknmC9bmqhAyf6AoBodaON2eU
1zb4Qh/1bG7fAEYuceYd2v4vPqWpkiK5Q5gHuBo5h3lYFjfOlcZN1BXqogp4AdAd
tnIAkyE5TCSxnd8gtgnR7eLT1XCD8Lhh1OmCIWAGecNV/XvzKB+Xk6pNBCqeCOhm
PsJickf+o8Ne2xdyOF0jdqq6KXbf6OS1zQUrvOsNls7YmVOK31NutppqVWop13Au
Vowbj/nqoVitd6vsW7Mbq5ibVqCp9/QIdV3p5L/6atNIk2X4J0vN1hN8C+nUpd1z
6yf0ZFnkPG0laRKmEr6J4UodIIFv3Axuhmb8HVp6/sh+oHxXCfhgU+u5M8LzMSUX
LZQDsvj3CK4s9NuF1U9Eyb3+H/M9h344l+GGrkrCifVV3RGqzZV9UAUyp1bUCYgm
jQC9/b74+oHcJrXv7LcM6wySXth40Tog5v4hDyrJgJirO+0I6ZKB1azbKoJ2fyIQ
bmlS8PxVJl/NLMtZBAjD
=p7KM
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--
