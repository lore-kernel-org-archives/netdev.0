From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 9/11] Add PHY master/slave #define override
Date: Mon, 8 Sep 2003 20:14:52 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081951150.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Add PHY master/slave #define override to address link issues
  with 82541/7 (rev2) against some low-end switches.  Forcing
  master will improve the time-to-link against these switches.

----------------

diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000.h linux-2.6.0-test4/drivers/net/e1000.new/e1000.h
--- linux-2.6.0-test4/drivers/net/e1000/e1000.h	2003-08-22 16:50:56.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000.h	2003-09-08 09:13:16.000000000 -0700
@@ -123,6 +123,11 @@ struct e1000_adapter;
 
 #define AUTO_ALL_MODES       0
 #define E1000_EEPROM_APME    0x0400
+
+#ifndef E1000_MASTER_SLAVE
+/* Switch to override PHY master/slave setting */
+#define E1000_MASTER_SLAVE	e1000_ms_hw_default
+#endif
 
 /* only works for sizes that are powers of 2 */
 #define E1000_ROUNDUP(i, size) ((i) = (((i) + (size) - 1) & ~((size) - 1)))
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_main.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_main.c	2003-08-22 16:54:23.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c	2003-09-08 09:13:11.000000000 -0700
@@ -641,6 +641,7 @@ e1000_sw_init(struct e1000_adapter *adap
 	if(hw->media_type == e1000_media_type_copper) {
 		hw->mdix = AUTO_ALL_MODES;
 		hw->disable_polarity_correction = FALSE;
+		hw->master_slave = E1000_MASTER_SLAVE;
 	}
 
 	atomic_set(&adapter->irq_sem, 1);
