From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] e100 driver crashes with ethtool
Date: Thu, 11 Dec 2003 17:07:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031211170720.2a5bb4ca.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>,
        "David S. Miller"
 <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The e100 driver in 2.6.0-test11 crashes when ever a ethtool command
would initiate a board reset.  The problem is bogus __devinit attributes
on functions that can be called from the ethtool ioctl code.

diff -Nru a/drivers/net/e100/e100_config.c b/drivers/net/e100/e100_config.c
--- a/drivers/net/e100/e100_config.c	Thu Dec 11 17:03:50 2003
+++ b/drivers/net/e100/e100_config.c	Thu Dec 11 17:03:50 2003
@@ -60,7 +60,7 @@
  * All other init functions will only set values that are
  * different from the 82557 default.
  */
-void __devinit
+void
 e100_config_init_82557(struct e100_private *bdp)
 {
 	/* initialize config block */
@@ -104,7 +104,7 @@
 	e100_config_mulcast_enbl(bdp, false);
 }
 
-static void __devinit
+static void
 e100_config_init_82558(struct e100_private *bdp)
 {
 	/* MWI enable. This should be turned on only if the adapter is a 82558/9
@@ -136,7 +136,7 @@
 	e100_config_long_rx(bdp, true);
 }
 
-static void __devinit
+static void
 e100_config_init_82550(struct e100_private *bdp)
 {
 	/* The D102 chip allows for 32 config bytes.  This value is
@@ -160,7 +160,7 @@
 }
 
 /* Initialize the adapter's configure block */
-void __devinit
+void
 e100_config_init(struct e100_private *bdp)
 {
 	e100_config_init_82557(bdp);
diff -Nru a/drivers/net/e100/e100_main.c b/drivers/net/e100/e100_main.c
--- a/drivers/net/e100/e100_main.c	Thu Dec 11 17:03:50 2003
+++ b/drivers/net/e100/e100_main.c	Thu Dec 11 17:03:50 2003
@@ -1290,7 +1290,7 @@
  *      true: if S/W was successfully initialized
  *      false: otherwise
  */
-static unsigned char __devinit
+static unsigned char
 e100_sw_init(struct e100_private *bdp)
 {
 	bdp->next_cu_cmd = START_WAIT;	// init the next cu state
@@ -1318,7 +1318,7 @@
 	return 1;
 }
 
-static void __devinit
+static void
 e100_tco_workaround(struct e100_private *bdp)
 {
 	int i;
@@ -2508,7 +2508,7 @@
  *      true: if successfully cleared stat counters
  *      false: otherwise
  */
-static unsigned char __devinit
+static unsigned char
 e100_clr_cntrs(struct e100_private *bdp)
 {
 	volatile u32 *pcmd_complete;
@@ -2873,7 +2873,7 @@
 /***************************************************************************/
 
 /* Read PWA (printed wired assembly) number */
-void __devinit
+static void __devinit
 e100_rd_pwa_no(struct e100_private *bdp)
 {
 	bdp->pwa_no = e100_eeprom_read(bdp, EEPROM_PWA_NO);
@@ -2882,7 +2882,7 @@
 }
 
 /* Read the permanent ethernet address from the eprom. */
-void __devinit
+static void __devinit
 e100_rd_eaddr(struct e100_private *bdp)
 {
 	int i;
diff -Nru a/drivers/net/e100/e100_phy.c b/drivers/net/e100/e100_phy.c
--- a/drivers/net/e100/e100_phy.c	Thu Dec 11 17:03:50 2003
+++ b/drivers/net/e100/e100_phy.c	Thu Dec 11 17:03:50 2003
@@ -132,7 +132,7 @@
 	}
 }
 
-static unsigned char __devinit
+static unsigned char
 e100_phy_valid(struct e100_private *bdp, unsigned int phy_address)
 {
 	u16 ctrl_reg, stat_reg;
@@ -150,7 +150,7 @@
 	return true;
 }
 
-static void __devinit
+static void
 e100_phy_address_detect(struct e100_private *bdp)
 {
 	unsigned int addr;
@@ -180,7 +180,7 @@
 	}
 }
 
-static void __devinit
+static void
 e100_phy_id_detect(struct e100_private *bdp)
 {
 	u16 low_id_reg, high_id_reg;
@@ -204,7 +204,7 @@
 		      ((unsigned int) high_id_reg << 16));
 }
 
-static void __devinit
+static void
 e100_phy_isolate(struct e100_private *bdp)
 {
 	unsigned int phy_address;
@@ -227,7 +227,7 @@
 	}
 }
 
-static unsigned char __devinit
+static unsigned char
 e100_phy_specific_setup(struct e100_private *bdp)
 {
 	u16 misc_reg;
@@ -380,7 +380,7 @@
  * Returns:
  *	NOTHING
  */
-static void __devinit
+static void
 e100_fix_polarity(struct e100_private *bdp)
 {
 	u16 status;
@@ -916,7 +916,7 @@
 	schedule_timeout(HZ / 2);
 }
 
-unsigned char __devinit
+unsigned char
 e100_phy_init(struct e100_private *bdp)
 {
 	e100_phy_reset(bdp);
