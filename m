From: Jason Lunz <lunz@falooley.org>
Subject: [patch] remove unused CONFIG_E100_NAPI
Date: Sun, 12 Dec 2004 04:26:31 +0000 (UTC)
Message-ID: <cpgh9m$7ls$1@sea.gmane.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have an old PII nfs media server running 2.6.10-rc3 with an intel
e100. Its interrupt is shared with both controllers of an siimage PCI
ide card:

[dunbar](1) # cat /proc/interrupts
           CPU0
  0:   16835371          XT-PIC  timer
  2:          0          XT-PIC  cascade
  8:          4          XT-PIC  rtc
 10:         75          XT-PIC  uhci_hcd
 11:    1685559          XT-PIC  ide2, ide3, eth0
 15:          0          XT-PIC  ide1
NMI:          0
LOC:          0
ERR:          0

With the eepro100 driver, a single tcp stream goes wirespeed in either
direction (11.2MB/s). With e100, the speed fluctuates wildly without
ever exceeding 2.5MB/s or so, and it averages around 1.

I thought it might be due to an interaction of napi and the shared
interrupt, so I tried disabling napi in the driver. Which was
frustrating, because it's no longer optional, despite what Kconfig says.

Jason

Signed-off-by: Jason Lunz <lunz@falooley.org>

--- linux-2.6.10-rc3/drivers/net/Kconfig.pre	2004-12-11 23:11:49.000000000 -0500
+++ linux-2.6.10-rc3/drivers/net/Kconfig	2004-12-11 23:12:13.000000000 -0500
@@ -1435,23 +1435,6 @@
 	  <file:Documentation/networking/net-modules.txt>.  The module
 	  will be called e100.
 
-config E100_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on E100
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card. It is
-	  still somewhat experimental and thus not yet enabled by default.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
-	  If in doubt, say N.
-
 config LNE390
 	tristate "Mylex EISA LNE390A/B support (EXPERIMENTAL)"
 	depends on NET_PCI && EISA && EXPERIMENTAL
