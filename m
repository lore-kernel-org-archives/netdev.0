From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igb: use correct bits to identify if managability is
	enabled
Date: Thu, 25 Mar 2010 20:15:06 -0700
Message-ID: <20100326031506.10368.40559.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:53537
	"EHLO qmta03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753125Ab0CZDPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 23:15:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

igb was previously checking the wrong bits in the MANC register to determine
if managability was enabled.  As a result it was incorrectly powering down and
resetting the phy when it didn't need to.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_mac.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 2a8a886..be8d010 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -1367,7 +1367,8 @@ out:
  *  igb_enable_mng_pass_thru - Enable processing of ARP's
  *  @hw: pointer to the HW structure
  *
- *  Verifies the hardware needs to allow ARPs to be processed by the host.
+ *  Verifies the hardware needs to leave interface enabled so that frames can
+ *  be directed to and from the management interface.
  **/
 bool igb_enable_mng_pass_thru(struct e1000_hw *hw)
 {
@@ -1380,8 +1381,7 @@ bool igb_enable_mng_pass_thru(struct e1000_hw *hw)
 
 	manc = rd32(E1000_MANC);
 
-	if (!(manc & E1000_MANC_RCV_TCO_EN) ||
-	    !(manc & E1000_MANC_EN_MAC_ADDR_FILTER))
+	if (!(manc & E1000_MANC_RCV_TCO_EN))
 		goto out;
 
 	if (hw->mac.arc_subsystem_valid) {

