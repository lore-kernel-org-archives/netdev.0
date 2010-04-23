From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: [PATCH 7/7] Topcliff GbE: Change The Kconfig and Makefile
Date: Fri, 23 Apr 2010 21:01:52 +0900
Message-ID: <003801cae2dd$216ecdc0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "NETDEV" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:34084 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757345Ab0DWMEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 08:04:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masayuki Ohtake <masa-korg@dsn.okisemi.com>

This patch change the Kconfig and Makefile of GbE driver for Topcliff.
The GbE driver needs all patch[1/7 to 7/7].

Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
---
 drivers/net/Kconfig                        | 5 ++
 drivers/net/Makefile                       | 1
 drivers/net/pch_gbe/Makefile               | 6
+++++++++++++++++++++++++++++++ 3 files changed, 12 insertions(+)
diff -urN linux-2.6.33.1/drivers/net/Kconfig
topcliff-2.6.33.1/drivers/net/Kconfig
--- linux-2.6.33.1/drivers/net/Kconfig 2010-03-16 01:09:39.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/Kconfig 2010-04-13 00:55:22.000000000
+0900
@@ -1977,6 +1977,11 @@
    If you say N, all options in this submenu will be skipped and disabled.

 if NETDEV_1000
+config PCH_GBE
+        tristate "PCH Gigabit Ethernet"
+        ---help---
+          This is an gigabit ethernet driver for PCH.
+          resources.

 config ACENIC
  tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"
diff -urN linux-2.6.33.1/drivers/net/Makefile
topcliff-2.6.33.1/drivers/net/Makefile
--- linux-2.6.33.1/drivers/net/Makefile 2010-03-16 01:09:39.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/Makefile 2010-04-13 00:55:22.000000000
+0900
@@ -287,3 +287,4 @@
 obj-$(CONFIG_WIMAX) += wimax/

 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
+obj-$(CONFIG_PCH_GBE) += pch_gbe/
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/Makefile
topcliff-2.6.33.1/drivers/net/pch_gbe/Makefile
--- linux-2.6.33.1/drivers/net/pch_gbe/Makefile 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/Makefile 2010-04-13
00:55:22.000000000 +0900
@@ -0,0 +1,6 @@
+ifeq ($(CONFIG_PCH_GBE_DEBUG_CORE),y)
+EXTRA_CFLAGS += -DDEBUG
+endif
+
+obj-$(CONFIG_PCH_GBE) += pch_gbe.o
+pch_gbe-objs := pch_gbe_mac.o pch_gbe_phy.o pch_gbe_nvm.o pch_gbe_ethtool.o
pch_gbe_plat.o pch_gbe_param.o pch_gbe_api.o pch_gbe_main.o

