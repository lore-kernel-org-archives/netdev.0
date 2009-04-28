From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/6] igb: reconfigure mailbox timeout logic
Date: Tue, 28 Apr 2009 01:34:54 -0700
Message-ID: <20090428083445.32417.77682.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:38216
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752055AbZD1IfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:35:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change updates the timeout logic so that it is not possible to have a
sucessful check for message and still return an error if countdown = 0.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Reported-by: Juha Leppanen <juha_motorsportscom@luukku.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_mbx.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/e1000_mbx.c b/drivers/net/igb/e1000_mbx.c
index 840782f..ed9058e 100644
--- a/drivers/net/igb/e1000_mbx.c
+++ b/drivers/net/igb/e1000_mbx.c
@@ -140,13 +140,13 @@ static s32 igb_poll_for_msg(struct e1000_hw *hw, u16 mbx_id)
 	struct e1000_mbx_info *mbx = &hw->mbx;
 	int countdown = mbx->timeout;
 
-	if (!mbx->ops.check_for_msg)
+	if (!countdown || !mbx->ops.check_for_msg)
 		goto out;
 
 	while (mbx->ops.check_for_msg(hw, mbx_id)) {
+		countdown--;
 		if (!countdown)
 			break;
-		countdown--;
 		udelay(mbx->usec_delay);
 	}
 out:
@@ -165,13 +165,13 @@ static s32 igb_poll_for_ack(struct e1000_hw *hw, u16 mbx_id)
 	struct e1000_mbx_info *mbx = &hw->mbx;
 	int countdown = mbx->timeout;
 
-	if (!mbx->ops.check_for_ack)
+	if (!countdown || !mbx->ops.check_for_ack)
 		goto out;
 
 	while (mbx->ops.check_for_ack(hw, mbx_id)) {
+		countdown--;
 		if (!countdown)
 			break;
-		countdown--;
 		udelay(mbx->usec_delay);
 	}
 out:

