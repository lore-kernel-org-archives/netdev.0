From: Axel Lin <axel.lin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net/wireless: use module_pci_driver
Date: Sat, 14 Apr 2012 10:38:36 +0800
Message-ID: <1334371116.17649.1.camel@phoenix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Simon Kelley <simon-xn1N/tgparsycpQjotevgVpr/1R2p/CL@public.gmane.org>,
	Jouni Malinen <j@w1.fi>,
	Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
	Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch converts the drivers in drivers/net/wireless/* to use
module_pci_driver() macro which makes the code smaller and a bit simpler.

Signed-off-by: Axel Lin <axel.lin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Cc: Simon Kelley <simon-xn1N/tgparsycpQjotevgVpr/1R2p/CL@public.gmane.org>
Cc: Jouni Malinen <j@w1.fi>
Cc: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Cc: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Cc: Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/wireless/adm8211.c              |   17 +----------------
 drivers/net/wireless/ath/ath5k/pci.c        |   26 +-------------------------
 drivers/net/wireless/atmel_pci.c            |   13 +------------
 drivers/net/wireless/hostap/hostap_pci.c    |   16 +---------------
 drivers/net/wireless/hostap/hostap_plx.c    |   16 +---------------
 drivers/net/wireless/mwl8k.c                |   13 +------------
 drivers/net/wireless/p54/p54pci.c           |   13 +------------
 drivers/net/wireless/rt2x00/rt2400pci.c     |   13 +------------
 drivers/net/wireless/rt2x00/rt2500pci.c     |   13 +------------
 drivers/net/wireless/rt2x00/rt61pci.c       |   13 +------------
 drivers/net/wireless/rtl818x/rtl8180/dev.c  |   13 +------------
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c |   19 +------------------
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c |   19 +------------------
 13 files changed, 13 insertions(+), 191 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index f5ce562..0ac09a2 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1991,19 +1991,4 @@ static struct pci_driver adm8211_driver = {
 #endif /* CONFIG_PM */
 };
 
-
-
-static int __init adm8211_init(void)
-{
-	return pci_register_driver(&adm8211_driver);
-}
-
-
-static void __exit adm8211_exit(void)
-{
-	pci_unregister_driver(&adm8211_driver);
-}
-
-
-module_init(adm8211_init);
-module_exit(adm8211_exit);
+module_pci_driver(adm8211_driver);
diff --git a/drivers/net/wireless/ath/ath5k/pci.c b/drivers/net/wireless/ath/ath5k/pci.c
index 53424e8..bbae8e2 100644
--- a/drivers/net/wireless/ath/ath5k/pci.c
+++ b/drivers/net/wireless/ath/ath5k/pci.c
@@ -339,28 +339,4 @@ static struct pci_driver ath5k_pci_driver = {
 	.driver.pm	= ATH5K_PM_OPS,
 };
 
-/*
- * Module init/exit functions
- */
-static int __init
-init_ath5k_pci(void)
-{
-	int ret;
-
-	ret = pci_register_driver(&ath5k_pci_driver);
-	if (ret) {
-		pr_err("pci: can't register pci driver\n");
-		return ret;
-	}
-
-	return 0;
-}
-
-static void __exit
-exit_ath5k_pci(void)
-{
-	pci_unregister_driver(&ath5k_pci_driver);
-}
-
-module_init(init_ath5k_pci);
-module_exit(exit_ath5k_pci);
+module_pci_driver(ath5k_pci_driver);
diff --git a/drivers/net/wireless/atmel_pci.c b/drivers/net/wireless/atmel_pci.c
index 9ab1192..51e33b5 100644
--- a/drivers/net/wireless/atmel_pci.c
+++ b/drivers/net/wireless/atmel_pci.c
@@ -74,15 +74,4 @@ static void __devexit atmel_pci_remove(struct pci_dev *pdev)
 	stop_atmel_card(pci_get_drvdata(pdev));
 }
 
-static int __init atmel_init_module(void)
-{
-	return pci_register_driver(&atmel_driver);
-}
-
-static void __exit atmel_cleanup_module(void)
-{
-	pci_unregister_driver(&atmel_driver);
-}
-
-module_init(atmel_init_module);
-module_exit(atmel_cleanup_module);
+module_pci_driver(atmel_driver);
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index 972a9c3..05ca340 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -457,18 +457,4 @@ static struct pci_driver prism2_pci_driver = {
 #endif /* CONFIG_PM */
 };
 
-
-static int __init init_prism2_pci(void)
-{
-	return pci_register_driver(&prism2_pci_driver);
-}
-
-
-static void __exit exit_prism2_pci(void)
-{
-	pci_unregister_driver(&prism2_pci_driver);
-}
-
-
-module_init(init_prism2_pci);
-module_exit(exit_prism2_pci);
+module_pci_driver(prism2_pci_driver);
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index 33e7903..c3d067e 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -616,18 +616,4 @@ static struct pci_driver prism2_plx_driver = {
 	.remove		= prism2_plx_remove,
 };
 
-
-static int __init init_prism2_plx(void)
-{
-	return pci_register_driver(&prism2_plx_driver);
-}
-
-
-static void __exit exit_prism2_plx(void)
-{
-	pci_unregister_driver(&prism2_plx_driver);
-}
-
-
-module_init(init_prism2_plx);
-module_exit(exit_prism2_plx);
+module_pci_driver(prism2_plx_driver);
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index b48674b..e30cc32 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -5893,18 +5893,7 @@ static struct pci_driver mwl8k_driver = {
 	.shutdown	= __devexit_p(mwl8k_shutdown),
 };
 
-static int __init mwl8k_init(void)
-{
-	return pci_register_driver(&mwl8k_driver);
-}
-
-static void __exit mwl8k_exit(void)
-{
-	pci_unregister_driver(&mwl8k_driver);
-}
-
-module_init(mwl8k_init);
-module_exit(mwl8k_exit);
+module_pci_driver(mwl8k_driver);
 
 MODULE_DESCRIPTION(MWL8K_DESC);
 MODULE_VERSION(MWL8K_VERSION);
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index 45df728..89318ad 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -667,15 +667,4 @@ static struct pci_driver p54p_driver = {
 	.driver.pm	= P54P_PM_OPS,
 };
 
-static int __init p54p_init(void)
-{
-	return pci_register_driver(&p54p_driver);
-}
-
-static void __exit p54p_exit(void)
-{
-	pci_unregister_driver(&p54p_driver);
-}
-
-module_init(p54p_init);
-module_exit(p54p_exit);
+module_pci_driver(p54p_driver);
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index 3a6b402..5e6b501 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -1828,15 +1828,4 @@ static struct pci_driver rt2400pci_driver = {
 	.resume		= rt2x00pci_resume,
 };
 
-static int __init rt2400pci_init(void)
-{
-	return pci_register_driver(&rt2400pci_driver);
-}
-
-static void __exit rt2400pci_exit(void)
-{
-	pci_unregister_driver(&rt2400pci_driver);
-}
-
-module_init(rt2400pci_init);
-module_exit(rt2400pci_exit);
+module_pci_driver(rt2400pci_driver);
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index dcc0e1f..136b849 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -2119,15 +2119,4 @@ static struct pci_driver rt2500pci_driver = {
 	.resume		= rt2x00pci_resume,
 };
 
-static int __init rt2500pci_init(void)
-{
-	return pci_register_driver(&rt2500pci_driver);
-}
-
-static void __exit rt2500pci_exit(void)
-{
-	pci_unregister_driver(&rt2500pci_driver);
-}
-
-module_init(rt2500pci_init);
-module_exit(rt2500pci_exit);
+module_pci_driver(rt2500pci_driver);
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index e0c6d11..ee22bd7 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -3092,15 +3092,4 @@ static struct pci_driver rt61pci_driver = {
 	.resume		= rt2x00pci_resume,
 };
 
-static int __init rt61pci_init(void)
-{
-	return pci_register_driver(&rt61pci_driver);
-}
-
-static void __exit rt61pci_exit(void)
-{
-	pci_unregister_driver(&rt61pci_driver);
-}
-
-module_init(rt61pci_init);
-module_exit(rt61pci_exit);
+module_pci_driver(rt61pci_driver);
diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wireless/rtl818x/rtl8180/dev.c
index 2f14a5f..2bebcb7 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -1173,15 +1173,4 @@ static struct pci_driver rtl8180_driver = {
 #endif /* CONFIG_PM */
 };
 
-static int __init rtl8180_init(void)
-{
-	return pci_register_driver(&rtl8180_driver);
-}
-
-static void __exit rtl8180_exit(void)
-{
-	pci_unregister_driver(&rtl8180_driver);
-}
-
-module_init(rtl8180_init);
-module_exit(rtl8180_exit);
+module_pci_driver(rtl8180_driver);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index 2c3b733..3aa927f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -389,21 +389,4 @@ static struct pci_driver rtl92ce_driver = {
 	.driver.pm = &rtlwifi_pm_ops,
 };
 
-static int __init rtl92ce_module_init(void)
-{
-	int ret;
-
-	ret = pci_register_driver(&rtl92ce_driver);
-	if (ret)
-		RT_ASSERT(false, "No device found\n");
-
-	return ret;
-}
-
-static void __exit rtl92ce_module_exit(void)
-{
-	pci_unregister_driver(&rtl92ce_driver);
-}
-
-module_init(rtl92ce_module_init);
-module_exit(rtl92ce_module_exit);
+module_pci_driver(rtl92ce_driver);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index f1b3600..730bcc9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -450,21 +450,4 @@ static struct pci_driver rtl92se_driver = {
 	.driver.pm = &rtlwifi_pm_ops,
 };
 
-static int __init rtl92se_module_init(void)
-{
-	int ret = 0;
-
-	ret = pci_register_driver(&rtl92se_driver);
-	if (ret)
-		RT_ASSERT(false, "No device found\n");
-
-	return ret;
-}
-
-static void __exit rtl92se_module_exit(void)
-{
-	pci_unregister_driver(&rtl92se_driver);
-}
