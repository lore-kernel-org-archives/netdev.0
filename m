From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/6] e1000e: Fix header includes [v2]
Date: Fri, 10 Aug 2007 13:00:38 -0700
Message-ID: <20070810200038.21509.77815.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andi@firstfloor.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25207 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761820AbXHJUAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:00:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c   |    4 ++++
 drivers/net/e1000e/e1000.h   |    7 ++++---
 drivers/net/e1000e/es2lan.c  |    5 +++++
 drivers/net/e1000e/ethtool.c |    3 ++-
 drivers/net/e1000e/hw.h      |    2 ++
 drivers/net/e1000e/ich8lan.c |    5 +++++
 drivers/net/e1000e/lib.c     |    2 ++
 drivers/net/e1000e/netdev.c  |    2 ++
 drivers/net/e1000e/phy.c     |    2 ++
 9 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index ddf2303..0f8f0ac 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -37,6 +37,10 @@
  * 82573L Gigabit Ethernet Controller
  */
 
+#include <linux/netdevice.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+
 #include "e1000.h"
 
 #define ID_LED_RESERVED_F746 0xF746
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index a1394d6..de17537 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -31,10 +31,11 @@
 #ifndef _E1000_H_
 #define _E1000_H_
 
+#include <linux/types.h>
+#include <linux/timer.h>
+#include <linux/workqueue.h>
+#include <linux/io.h>
 #include <linux/netdevice.h>
-#include <linux/ethtool.h>
-#include <linux/pci.h>
-#include <asm/io.h>
 
 #include "hw.h"
 
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 5604c50..8100d03 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -31,6 +31,11 @@
  * 80003ES2LAN Gigabit Ethernet Controller (Serdes)
  */
 
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+
 #include "e1000.h"
 
 #define E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL	 0x00
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 6c417ea..a8fa1db 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -29,8 +29,9 @@
 /* ethtool support for e1000 */
 
 #include <linux/netdevice.h>
-
 #include <linux/ethtool.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
 
 #include "e1000.h"
 
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 4d562c4..848217a 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -29,6 +29,8 @@
 #ifndef _E1000_HW_H_
 #define _E1000_HW_H_
 
+#include <linux/types.h>
+
 struct e1000_hw;
 struct e1000_adapter;
 
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 042abd4..85095af 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -40,6 +40,11 @@
  * 82566MM Gigabit Network Connection
  */
 
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+
 #include "e1000.h"
 
 #define ICH_FLASH_GFPREG		0x0000
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 3bbe63e..c92ea77 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -27,6 +27,8 @@
 *******************************************************************************/
 
 #include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/delay.h>
 #include <linux/pci.h>
 
 #include "e1000.h"
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 741965d..01a9a4f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -29,8 +29,10 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
+#include <linux/pci.h>
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
+#include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/tcp.h>
 #include <linux/ipv6.h>
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 1ccbad7..c9304d8 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -26,6 +26,8 @@
 
 *******************************************************************************/
 
+#include <linux/delay.h>
+
 #include "e1000.h"
 
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
