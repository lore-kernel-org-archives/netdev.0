From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: use the broken_parity_status field in pci_dev
Date: Mon, 18 Dec 2006 00:04:19 +0100
Message-ID: <20061217230419.GB26485@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48030 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188AbWLQXGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Dec 2006 18:06:16 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The former option is removed and platform code can now specify the
expected behavior.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f83b41d..1489100 100644
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
 
@@ -2388,7 +2385,7 @@ static void rtl8169_pcierr_interrupt(str
 	 *
 	 * Feel free to adjust to your needs.
 	 */
-	if (ignore_parity_err)
+	if (pdev->broken_parity_status)
 		pci_cmd &= ~PCI_COMMAND_PARITY;
 	else
 		pci_cmd |= PCI_COMMAND_SERR | PCI_COMMAND_PARITY;
-- 
1.4.2.3
