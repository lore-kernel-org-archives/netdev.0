From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000e: workaround hw errata
Date: Fri, 23 Jan 2009 17:35:31 -0800
Message-ID: <20090124013527.2832.92374.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:41807
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753527AbZAXBfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 20:35:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

There is a hardware errata in some revisions of the 82574 that needs
to be worked around in the driver by setting a register bit at init.

If this bit is not set A0 versions of the 82574 can generate
tx hangs.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c |    6 +++++-
 drivers/net/e1000e/hw.h    |    1 +
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index cf43ee7..0890162 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -981,11 +981,15 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 		ew32(PBA_ECC, reg);
 	}
 
-	/* PCI-Ex Control Register */
+	/* PCI-Ex Control Registers */
 	if (hw->mac.type == e1000_82574) {
 		reg = er32(GCR);
 		reg |= (1 << 22);
 		ew32(GCR, reg);
+
+		reg = er32(GCR2);
+		reg |= 1;
+		ew32(GCR2, reg);
 	}
 
 	return;
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index f25e961..2d4ce04 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -206,6 +206,7 @@ enum e1e_registers {
 	E1000_MANC2H    = 0x05860, /* Management Control To Host - RW */
 	E1000_SW_FW_SYNC = 0x05B5C, /* Software-Firmware Synchronization - RW */
 	E1000_GCR	= 0x05B00, /* PCI-Ex Control */
+	E1000_GCR2      = 0x05B64, /* PCI-Ex Control #2 */
 	E1000_FACTPS    = 0x05B30, /* Function Active and Power State to MNG */
 	E1000_SWSM      = 0x05B50, /* SW Semaphore */
 	E1000_FWSM      = 0x05B54, /* FW Semaphore */

