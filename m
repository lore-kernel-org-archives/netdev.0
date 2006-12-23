From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'r8169-upstream-20061223-00' tag
Date: Sat, 23 Dec 2006 17:49:11 +0100
Message-ID: <20061223164911.GA16360@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46298 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753585AbWLWQum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Dec 2006 11:50:42 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from tag 'r8169-upstream-20061223-00' in repository

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git tag r8169-upstream-20061223-00

to get the changes below.

PS: the same changes are available in branch 'r8169' which forked from
the main trunk at 18ed1c051317ac3a685120cead2adb192b802347 so that
akpm's scripts pull everything automatically during xmas.

Distance from 'netdev-2.6/upstream-fixes'
-----------------------------------------

7e5571a2c58313b995003d787e527f792dea3c62
50deea7d262363894f2e13345979a38e3d93b1bb
18d6ba1273df62f13a70eed8dbeae7c5d59ab6e2 <- current 'upstream-fixes' at korg

Diffstat
--------

 drivers/net/r8169.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

Shortlog
--------

Francois Romieu:
      r8169: remove extraneous Cmd{Tx/Rx}Enb write

Lennert Buytenhek:
      r8169: use the broken_parity_status field in pci_dev

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f83b41d..577babd 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -225,7 +225,6 @@ MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl
 
 static int rx_copybreak = 200;
 static int use_dac;
-static int ignore_parity_err;
 static struct {
 	u32 msg_enable;
 } debug = { -1 };
@@ -471,8 +470,6 @@ module_param(use_dac, int, 0);
 MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
 module_param_named(debug, debug.msg_enable, int, 0);
 MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
-module_param_named(ignore_parity_err, ignore_parity_err, bool, 0);
-MODULE_PARM_DESC(ignore_parity_err, "Ignore PCI parity error as target. Default: false");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(RTL8169_VERSION);
 
@@ -1885,7 +1882,6 @@ static void rtl8169_hw_start(struct net_
 	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
-		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 		rtl8169_set_rx_tx_config_registers(tp);
 
 	cmd = RTL_R16(CPlusCmd);
@@ -2388,7 +2384,7 @@ static void rtl8169_pcierr_interrupt(str
 	 *
 	 * Feel free to adjust to your needs.
 	 */
-	if (ignore_parity_err)
+	if (pdev->broken_parity_status)
 		pci_cmd &= ~PCI_COMMAND_PARITY;
 	else
 		pci_cmd |= PCI_COMMAND_SERR | PCI_COMMAND_PARITY;
-- 
Ueimor
