From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 15/18] wireless Kconfig add IPW2200_RADIOTAP
Date: Thu, 13 Apr 2006 17:20:54 +0800
Message-ID: <20060413092054.GA28808@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:32938 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S964854AbWDMJ16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:27:58 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Makefile both IPW2200_RADIOTAP and IPW2200_PROMISCUOUS depend on
IPW2200_MONITOR. Let IPW2200_PROMISCUOUS select IPW2200_RADIOTAP.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/Kconfig |   52 +++++++++++++++++++++++-------------------
 1 files changed, 28 insertions(+), 24 deletions(-)

d2baa760aa4ba72495da0ada29f877470f687de3
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 073b4a3..2da2833 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -235,6 +235,34 @@ config IPW2200_MONITOR
 	  promiscuous mode via the Wireless Tool's Monitor mode.  While in this
 	  mode, no packets can be sent.
 
+config IPW2200_RADIOTAP
+	bool "Enable radiotap format 802.11 raw packet support"
+	depends on IPW2200_MONITOR
+
+config IPW2200_PROMISCUOUS
+	bool "Enable creation of a RF radiotap promiscuous interface"
+	depends on IPW2200_MONITOR
+	select IPW2200_RADIOTAP
+	---help---
+          Enables the creation of a second interface prefixed 'rtap'. 
+          This second interface will provide every received in radiotap
+	  format.
+
+          This is useful for performing wireless network analysis while
+          maintaining an active association.
+
+          Example usage:
+
+            % modprobe ipw2200 rtap_iface=1
+            % ifconfig rtap0 up
+            % tethereal -i rtap0
+
+          If you do not specify 'rtap_iface=1' as a module parameter then 
+          the rtap interface will not be created and you will need to turn 
+          it on via sysfs:
+	
+            % echo 1 > /sys/bus/pci/drivers/ipw2200/*/rtap_iface
+
 config IPW2200_QOS
         bool "Enable QoS support"
         depends on IPW2200 && EXPERIMENTAL
@@ -263,30 +291,6 @@ config IPW2200_DEBUG
 	  If you are not trying to debug or develop the IPW2200 driver, you 
 	  most likely want to say N here.
 
-config IPW2200_PROMISCUOUS
-	bool "Enable creation of a RF radiotap promiscuous interface."
-	depends on IPW2200
-	select IEEE80211_RADIOTAP
-	---help---
-          Enables the creation of a second interface prefixed 'rtap'. 
-          This second interface will provide every received in radiotap
-	  format.
-
-          This is useful for performing wireless network analysis while
-          maintaining an active association.
-
-          Example usage:
-
-            % modprobe ipw2200 rtap_iface=1
-            % ifconfig rtap0 up
-            % tethereal -i rtap0
-
-          If you do not specify 'rtap_iface=1' as a module parameter then 
-          the rtap interface will not be created and you will need to turn 
-          it on via sysfs:
-	
-            % echo 1 > /sys/bus/pci/drivers/ipw2200/*/rtap_iface
-
 config AIRO
 	tristate "Cisco/Aironet 34X/35X/4500/4800 ISA and PCI cards"
  	depends on NET_RADIO && ISA_DMA_API && (PCI || BROKEN)
-- 
1.2.6

