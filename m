From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [e1000] print bus type/speed/width on probe
Date: Wed, 24 Nov 2004 16:15:17 +0100
Message-ID: <20041124151517.GA17448@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: ganesh.venkatesan@intel.com, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The attached patch (based on a patch by Robert Olsson) makes e1000
display bus type/speed/width on probe.  All this info is already
determined by e1000_hw.  Output is as such (a la tg3):

eth1: e1000 (PCI:33MHz:32-bit) 00:0e:0c:64:cc:a1
eth2: e1000 (PCI:66MHz:32-bit) 00:04:23:46:e2:50

I've found it useful -- please consider applying.


cheers,
Lennert


Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

diff -urN e1000.orig/e1000_main.c e1000/e1000_main.c
--- e1000.orig/e1000_main.c	2004-11-24 15:35:23.000000000 +0100
+++ e1000/e1000_main.c	2004-11-24 16:04:30.000000000 +0100
@@ -585,6 +585,21 @@
 	if(eeprom_data & E1000_EEPROM_APME)
 		adapter->wol |= E1000_WUFC_MAG;
 
+	/* print bus type/speed/width info */
+	printk(KERN_INFO "%s: e1000 (PCI%s:%s:%s) ", netdev->name,
+		((adapter->hw.bus_type == e1000_bus_type_pcix) ? "X" : ""),
+		((adapter->hw.bus_speed == e1000_bus_speed_133) ? "133MHz" :
+		 (adapter->hw.bus_speed == e1000_bus_speed_120) ? "120MHz" :
+		 (adapter->hw.bus_speed == e1000_bus_speed_100) ? "100MHz" :
+		 (adapter->hw.bus_speed == e1000_bus_speed_66) ? "66MHz" :
+		  "33MHz"),
+		((adapter->hw.bus_width == e1000_bus_width_64) ? "64-bit" :
+		  "32-bit"));
+
+	for (i = 0; i < 6; i++)
+		printk("%2.2x%c", netdev->dev_addr[i],
+			i == 5 ? '\n' : ':');
+
 	/* reset the hardware with the new settings */
 	e1000_reset(adapter);
 
