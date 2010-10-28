From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH] Fix missing dependency of PCH_GBE driver
Date: Thu, 28 Oct 2010 08:16:29 -0400
Message-ID: <1288268189.18238.173.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Dan Carpenter <error27@gmail.com>,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.124]:33201 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932988Ab0J1MQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 08:16:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While doing some randconfigs I stumbled across this build error:

ERROR: "mii_ethtool_gset" [drivers/net/pch_gbe/pch_gbe.ko] undefined!
ERROR: "generic_mii_ioctl" [drivers/net/pch_gbe/pch_gbe.ko] undefined!
ERROR: "mii_nway_restart" [drivers/net/pch_gbe/pch_gbe.ko] undefined!
ERROR: "mii_check_gmii_support" [drivers/net/pch_gbe/pch_gbe.ko] undefined!
ERROR: "mii_link_ok" [drivers/net/pch_gbe/pch_gbe.ko] undefined!
ERROR: "mii_ethtool_sset" [drivers/net/pch_gbe/pch_gbe.ko] undefined!

The config option PCH_GBE is missing the dependency of MII.

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9334539..cf9769c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2540,7 +2540,7 @@ source "drivers/net/stmmac/Kconfig"
 
 config PCH_GBE
 	tristate "PCH Gigabit Ethernet"
-	depends on PCI
+	depends on PCI && MII
 	---help---
 	  This is a gigabit ethernet driver for Topcliff PCH.
 	  Topcliff PCH is the platform controller hub that is used in Intel's


