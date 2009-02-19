From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 7/7] fcoe: fcoe fc crc offload indication by skb->ip_summed
Date: Thu, 19 Feb 2009 12:50:31 -0700
Message-ID: <20090219195031.22270.35911.stgit.yi.zou@intel.com>
References: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10193 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757972AbZBSU5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 15:57:39 -0500
In-Reply-To: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If LLD supports FCCRC offload, it should set ip_summed to be
CHECKSUM_UNNECESSARY so we don't have to do CRC check again.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/scsi/fcoe/libfcoe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/fcoe/libfcoe.c b/drivers/scsi/fcoe/libfcoe.c
index 3072428..2a34832 100644
--- a/drivers/scsi/fcoe/libfcoe.c
+++ b/drivers/scsi/fcoe/libfcoe.c
@@ -624,7 +624,7 @@ int fcoe_percpu_receive_thread(void *arg)
 		 * it's solicited data, in which case, the FCP layer would
 		 * check it during the copy.
 		 */
-		if (lp->crc_offload)
+		if (lp->crc_offload && skb->ip_summed == CHECKSUM_UNNECESSARY)
 			fr_flags(fp) &= ~FCPHF_CRC_UNCHECKED;
 		else
 			fr_flags(fp) |= FCPHF_CRC_UNCHECKED;

