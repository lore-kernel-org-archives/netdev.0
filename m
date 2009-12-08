From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/3] e1000e: replace incorrect use of GG82563_REG macro
Date: Tue, 08 Dec 2009 09:28:01 -0800
Message-ID: <20091208172800.19741.84491.stgit@localhost.localdomain>
References: <20091208172725.19741.25809.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:52048
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936868AbZLHR2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 12:28:12 -0500
In-Reply-To: <20091208172725.19741.25809.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The GG82563_REG() macro should not be used to determine the offset provided
to the e1000e_[read|write]_kmrn_reg() functions since the first argument to
the macro is already implied and gets masked off anyway in the functions.
The resultant register reads/writes with this patch are functionally the
same as before.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/hw.h      |    2 ++
 drivers/net/e1000e/ich8lan.c |    8 +++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index a7d08da..5ed1788 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -302,6 +302,8 @@ enum e1e_registers {
 #define E1000_KMRNCTRLSTA_OFFSET_SHIFT	16
 #define E1000_KMRNCTRLSTA_REN		0x00200000
 #define E1000_KMRNCTRLSTA_DIAG_OFFSET	0x3    /* Kumeran Diagnostic */
+#define E1000_KMRNCTRLSTA_TIMEOUTS	0x4    /* Kumeran Timeouts */
+#define E1000_KMRNCTRLSTA_INBAND_PARAM	0x9    /* Kumeran InBand Parameters */
 #define E1000_KMRNCTRLSTA_DIAG_NELPBK	0x1000 /* Nearend Loopback mode */
 #define E1000_KMRNCTRLSTA_K1_CONFIG	0x7
 #define E1000_KMRNCTRLSTA_K1_ENABLE	0x140E
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 7b33be9..9b09246 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2755,14 +2755,16 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 	 * and increase the max iterations when polling the phy;
 	 * this fixes erroneous timeouts at 10Mbps.
 	 */
-	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_TIMEOUTS, 0xFFFF);
 	if (ret_val)
 		return ret_val;
-	ret_val = e1000e_read_kmrn_reg(hw, GG82563_REG(0x34, 9), &reg_data);
+	ret_val = e1000e_read_kmrn_reg(hw, E1000_KMRNCTRLSTA_INBAND_PARAM,
+	                               &reg_data);
 	if (ret_val)
 		return ret_val;
 	reg_data |= 0x3F;
-	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 9), reg_data);
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_INBAND_PARAM,
+	                                reg_data);
 	if (ret_val)
 		return ret_val;
 

