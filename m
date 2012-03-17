From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] fcoe: use CHECKSUM_UNNECESSARY instead of CHECKSUM_PARTIAL on tx
Date: Sat, 17 Mar 2012 02:08:12 -0700
Message-ID: <1331975292-19521-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331975292-19521-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yi Zou <yi.zou@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Robert Love <robert.w.love@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33772 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932170Ab2CQJIP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 05:08:15 -0400
In-Reply-To: <1331975292-19521-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Fix a bug when using 'ethtool -K ethx tx off' to turn off tx ip checksum,
FCoE CRC offload should not be impacte. The skb_checksum_help() is needed
only if it's not FCoE traffic for ip checksum, regardless of ethtool toggling
the tx ip checksum on or off. Instead of using CHECKSUM_PARTIAL, we will
use CHECKSUM_UNNECESSARY as a proper indication to avoid sw ip checksum
on FCoE frames.

Ref. to original discussion thread:
http://patchwork.ozlabs.org/patch/146567/

CC: "James E.J. Bottomley" <JBottomley@parallels.com>
CC: Robert Love <robert.w.love@intel.com>
Signed-off-by: Yi Zou <yi.zou@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/scsi/fcoe/fcoe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index e959960..c164890 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1498,7 +1498,7 @@ static int fcoe_xmit(struct fc_lport *lport, struct fc_frame *fp)
 
 	/* crc offload */
 	if (likely(lport->crc_offload)) {
-		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 		skb->csum_start = skb_headroom(skb);
 		skb->csum_offset = skb->len;
 		crc = 0;
-- 
1.7.7.6
