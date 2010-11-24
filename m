From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 3/6] net: add some KERN_CONT markers to continuation lines
Date: Wed, 24 Nov 2010 09:57:47 +0100
Message-ID: <1290589070-854-3-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20101124085645.GW4693@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	kernel@pengutronix.de, Arjan van de Ven <arjan@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57890 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967Ab0KXI6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 03:58:12 -0500
In-Reply-To: <20101124085645.GW4693@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: netdev@vger.kernel.org
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/phy/phy.c |    4 ++--
 net/ipv4/ipconfig.c   |   32 ++++++++++++++++----------------
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 7670aac..a8445c7 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -47,11 +47,11 @@ void phy_print_status(struct phy_device *phydev)
 	pr_info("PHY: %s - Link is %s", dev_name(&phydev->dev),
 			phydev->link ? "Up" : "Down");
 	if (phydev->link)
-		printk(" - %d/%s", phydev->speed,
+		printk(KERN_CONT " - %d/%s", phydev->speed,
 				DUPLEX_FULL =3D=3D phydev->duplex ?
 				"Full" : "Half");
=20
-	printk("\n");
+	printk(KERN_CONT "\n");
 }
 EXPORT_SYMBOL(phy_print_status);
=20
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 3a6e1ec..2b09775 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1191,13 +1191,13 @@ static int __init ic_dynamic(void)
 		    (ic_proto_enabled & IC_USE_DHCP) &&
 		    ic_dhcp_msgtype !=3D DHCPACK) {
 			ic_got_reply =3D 0;
-			printk(",");
+			printk(KERN_CONT ",");
 			continue;
 		}
 #endif /* IPCONFIG_DHCP */
=20
 		if (ic_got_reply) {
-			printk(" OK\n");
+			printk(KERN_CONT " OK\n");
 			break;
 		}
=20
@@ -1205,7 +1205,7 @@ static int __init ic_dynamic(void)
 			continue;
=20
 		if (! --retries) {
-			printk(" timed out!\n");
+			printk(KERN_CONT " timed out!\n");
 			break;
 		}
=20
@@ -1215,7 +1215,7 @@ static int __init ic_dynamic(void)
 		if (timeout > CONF_TIMEOUT_MAX)
 			timeout =3D CONF_TIMEOUT_MAX;
=20
-		printk(".");
+		printk(KERN_CONT ".");
 	}
=20
 #ifdef IPCONFIG_BOOTP
@@ -1236,7 +1236,7 @@ static int __init ic_dynamic(void)
 		((ic_got_reply & IC_RARP) ? "RARP"
 		 : (ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP"),
 		&ic_servaddr);
-	printk("my address is %pI4\n", &ic_myaddr);
+	printk(KERN_CONT "my address is %pI4\n", &ic_myaddr);
=20
 	return 0;
 }
@@ -1468,19 +1468,19 @@ static int __init ip_auto_config(void)
 	/*
 	 * Clue in the operator.
 	 */
-	printk("IP-Config: Complete:");
-	printk("\n     device=3D%s", ic_dev->name);
-	printk(", addr=3D%pI4", &ic_myaddr);
-	printk(", mask=3D%pI4", &ic_netmask);
-	printk(", gw=3D%pI4", &ic_gateway);
-	printk(",\n     host=3D%s, domain=3D%s, nis-domain=3D%s",
+	printk("IP-Config: Complete:\n");
+	printk("     device=3D%s", ic_dev->name);
+	printk(KERN_CONT ", addr=3D%pI4", &ic_myaddr);
+	printk(KERN_CONT ", mask=3D%pI4", &ic_netmask);
+	printk(KERN_CONT ", gw=3D%pI4", &ic_gateway);
+	printk(KERN_CONT ",\n     host=3D%s, domain=3D%s, nis-domain=3D%s",
 	       utsname()->nodename, ic_domain, utsname()->domainname);
-	printk(",\n     bootserver=3D%pI4", &ic_servaddr);
-	printk(", rootserver=3D%pI4", &root_server_addr);
-	printk(", rootpath=3D%s", root_server_path);
+	printk(KERN_CONT ",\n     bootserver=3D%pI4", &ic_servaddr);
+	printk(KERN_CONT ", rootserver=3D%pI4", &root_server_addr);
+	printk(KERN_CONT ", rootpath=3D%s", root_server_path);
 	if (ic_dev_mtu)
-		printk(", mtu=3D%d", ic_dev_mtu);
-	printk("\n");
+		printk(KERN_CONT ", mtu=3D%d", ic_dev_mtu);
+	printk(KERN_CONT "\n");
 #endif /* !SILENT */
=20
 	return 0;
--=20
1.7.2.3

