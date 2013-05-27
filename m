From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 3/6] bnx2x: Ack unknown VF messages
Date: Mon, 27 May 2013 17:08:28 +0300
Message-ID: <1369663711-32146-4-git-send-email-yuvalmin@broadcom.com>
References: <1369663711-32146-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4341 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932608Ab3E0OJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 10:09:02 -0400
In-Reply-To: <1369663711-32146-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

A PF should ack the firmware when receiving unknown messages through the VF's
mailbox. This prevents the VF mailbox from being stuck in case of a VF sending
a message unknown to the PF (e.g. VF with more advanced version).

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 928b074..2826066 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1605,8 +1605,11 @@ static void bnx2x_vf_mbx_request(struct bnx2x *bp, struct bnx2x_virtf *vf,
 			bnx2x_vf_mbx_resp(bp, vf);
 		} else {
 			/* can't send a response since this VF is unknown to us
-			 * just unlock the channel and be done with.
+			 * just ack the FW to release the mailbox and unlock
+			 * the channel.
 			 */
+			storm_memset_vf_mbx_ack(bp, vf->abs_vfid);
+			mmiowb();
 			bnx2x_unlock_vf_pf_channel(bp, vf,
 						   mbx->first_tlv.tl.type);
 		}
-- 
1.8.1.227.g44fe835
