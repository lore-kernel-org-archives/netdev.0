From: Colin King <colin.king@canonical.com>
Subject: [PATCH] liquidio CN23XX: check if PENDING bit is clear using logical and
Date: Fri, 18 Nov 2016 18:45:32 +0000
Message-ID: <20161118184532.5282-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:50580 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753014AbcKRSpp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 13:45:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

the mbox state should be bitwise anded rather than logically anded
with OCTEON_MBOX_STATE_RESPONSE_PENDING. Fix this by using the
correct & operator instead of &&.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
index 5309384..73696b42 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
@@ -301,7 +301,7 @@ int octeon_mbox_process_message(struct octeon_mbox *mbox)
 		       sizeof(struct octeon_mbox_cmd));
 		if (!mbox_cmd.msg.s.resp_needed) {
 			mbox->state &= ~OCTEON_MBOX_STATE_REQUEST_RECEIVED;
-			if (!(mbox->state &&
+			if (!(mbox->state &
 			      OCTEON_MBOX_STATE_RESPONSE_PENDING))
 				mbox->state = OCTEON_MBOX_STATE_IDLE;
 			writeq(OCTEON_PFVFSIG, mbox->mbox_read_reg);
-- 
2.10.2
