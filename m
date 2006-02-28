From: Carlos Martin <carlos@cmartin.tk>
Subject: [PATCH 2/7] acxsm: Move module init/exit to the modules
Date: Tue, 28 Feb 2006 17:30:14 +0100
Message-ID: <11411442143394-git-send-email-carlos@cmartin.tk>
References: <1141144213577-git-send-email-carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Denis Vlasenko <vda@ilport.com.ua>,
	acx100-devel@lists.sourceforge.net,
	Christoph Hellwig <hch@infradead.org>,
	Carlos Martin <carlos@kiopa. (none)>,
	Carlos Martin <carlos@cmartin.tk>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
In-Reply-To: <1141144213577-git-send-email-carlos@cmartin.tk>
To: netdev@vger.kernel.org
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

We now have the module license and init/exit routines in each module
instead of just calling them through common.c.

Signed-off-by: Carlos Martin <carlos@cmartin.tk>

---

 common.c |   55 +------------------------------------------------------
 pci.c    |   10 ++++++++++
 usb.c    |   11 ++++++++++-
 3 files changed, 21 insertions(+), 55 deletions(-)

147a9817d6d762545fc7c5efc124281b7c8ca8fb
diff --git a/common.c b/common.c
index 7f10725..a78b643 100644
--- a/common.c
+++ b/common.c
@@ -94,7 +94,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 #endif
 /* USB had this: MODULE_AUTHOR("Martin Wawro <martin.wawro AT uni-dortmu=
nd.de>"); */
 MODULE_AUTHOR("ACX100 Open Source Driver development team");
-MODULE_DESCRIPTION("Driver for TI ACX1xx based wireless cards (CardBus/P=
CI/USB)");
+MODULE_DESCRIPTION("Driver for TI ACX1xx based wireless cards (common)")=
;
=20
=20
 /***********************************************************************
@@ -7407,59 +7407,6 @@ acx_s_parse_configoption(acx_device_t *a
 }
=20
=20
-/***********************************************************************
-*/
-static int __init
-acx_e_init_module(void)
-{
-	int r1,r2;
-
-	acx_struct_size_check();
-
-	printk("acx: this driver is still EXPERIMENTAL\n"
-		"acx: reading README file and/or Craig's HOWTO is "
-		"recommended, visit http://acx100.sf.net in case "
-		"of further questions/discussion\n");
-
-#if defined(CONFIG_ACX_PCI)
-	r1 =3D acxpci_e_init_module();
-#else
-	r1 =3D -EINVAL;
-#endif
-#if defined(CONFIG_ACX_USB)
-	r2 =3D acxusb_e_init_module();
-#else
-	r2 =3D -EINVAL;
-#endif
-	if (r2 && r1) /* both failed! */
-		return r2 ? r2 : r1;
-	/* return success if at least one succeeded */
-	return 0;
-}
-
-static void __exit
-acx_e_cleanup_module(void)
-{
-#if defined(CONFIG_ACX_PCI)
-	acxpci_e_cleanup_module();
-#endif
-#if defined(CONFIG_ACX_USB)
-	acxusb_e_cleanup_module();
-#endif
-}
-
-module_init(acx_e_init_module)
-module_exit(acx_e_cleanup_module)
-
-
-
-
-
-
-
-
-
-
 //SM
 void
 acx_e_ieee80211_set_security(struct net_device *ndev,
diff --git a/pci.c b/pci.c
index ea9bee0..24224b9 100644
--- a/pci.c
+++ b/pci.c
@@ -105,6 +105,13 @@ static int acxpci_e_close(struct net_dev
 static void acxpci_s_up(struct net_device *ndev);
 static void acxpci_s_down(struct net_device *ndev);
=20
+#ifdef MODULE_LICENSE
+MODULE_LICENSE("Dual MPL/GPL");
+#endif
+/* USB had this: MODULE_AUTHOR("Martin Wawro <martin.wawro AT uni-dortmu=
nd.de>"); */
+MODULE_AUTHOR("ACX100 Open Source Driver development team");
+MODULE_DESCRIPTION("Driver for TI ACX1xx based wireless cards (CardBus/P=
CI)");
+
=20
 /***********************************************************************
 ** Register access
@@ -4192,3 +4199,6 @@ acxpci_e_cleanup_module(void)
=20
 	FN_EXIT0;
 }
+
+module_init(acxpci_e_init_module);
+module_exit(acxpci_e_cleanup_module);
diff --git a/usb.c b/usb.c
index 116cf90..6b0b578 100644
--- a/usb.c
+++ b/usb.c
@@ -127,6 +127,14 @@ static void acxusb_i_tx_timeout(struct n
 /* static void dump_device_descriptor(struct usb_device_descriptor *); *=
/
 /* static void dump_config_descriptor(struct usb_config_descriptor *); *=
/
=20
+#ifdef MODULE_LICENSE
+MODULE_LICENSE("Dual MPL/GPL");
+#endif
+/* USB had this: MODULE_AUTHOR("Martin Wawro <martin.wawro AT uni-dortmu=
nd.de>"); */
+MODULE_AUTHOR("ACX100 Open Source Driver development team");
+MODULE_DESCRIPTION("Driver for TI ACX1xx based wireless cards (USB)");
+
+
 /***********************************************************************
 ** Module Data
 */
@@ -1811,7 +1819,8 @@ acxusb_e_cleanup_module()
 	usb_deregister(&acxusb_driver);
 }
=20
-
+module_init(acxusb_e_init_module);
+module_exit(acxusb_e_cleanup_module);
 /***********************************************************************
 ** DEBUG STUFF
 */
--=20
1.2.1.g62a4




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
