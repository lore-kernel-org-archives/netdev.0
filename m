From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 06/12] e1000e: Remove EN_MAC_ADDR_FILTER check
	from enable_mng_pass_thru check
Date: Mon, 10 May 2010 18:00:50 -0700
Message-ID: <20100511010048.30827.12737.stgit@localhost.localdomain>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:47506
	"EHLO qmta07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757406Ab0EKBBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 21:01:09 -0400
In-Reply-To: <20100511005801.30827.50808.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Patch addresses issues when manageability passthrough is enabled, but the
MAC_ADDR_FILTER bit is not set in the MANC register.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/lib.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index b0d2a60..b32361d 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -2515,10 +2515,11 @@ s32 e1000e_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length)
 }
 
 /**
- *  e1000e_enable_mng_pass_thru - Enable processing of ARP's
+ *  e1000e_enable_mng_pass_thru - Check if management passthrough is needed
  *  @hw: pointer to the HW structure
  *
- *  Verifies the hardware needs to allow ARPs to be processed by the host.
+ *  Verifies the hardware needs to leave interface enabled so that frames can
+ *  be directed to and from the management interface.
  **/
 bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw)
 {
@@ -2528,8 +2529,7 @@ bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw)
 
 	manc = er32(MANC);
 
-	if (!(manc & E1000_MANC_RCV_TCO_EN) ||
-	    !(manc & E1000_MANC_EN_MAC_ADDR_FILTER))
+	if (!(manc & E1000_MANC_RCV_TCO_EN))
 		return ret_val;
 
 	if (hw->mac.arc_subsystem_valid) {

