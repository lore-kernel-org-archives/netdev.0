From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 11/11] fcoe: fcoe fc crc offload indication by skb->ip_summed
Date: Fri, 27 Feb 2009 14:07:31 -0800
Message-ID: <20090227220731.4987.84514.stgit.yi.zou@intel.com>
References: <20090227220034.4987.50755.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32993 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759212AbZB0XPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 18:15:08 -0500
In-Reply-To: <20090227220034.4987.50755.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If LLD supports FCCRC offload, it should set ip_summed to be
CHECKSUM_UNNECESSARY so we don't have to do CRC check again.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/scsi/fcoe/libfcoe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/fcoe/libfcoe.c b/drivers/scsi/fcoe/libfcoe.c
index 5dae823..0d6f5be 100644
--- a/drivers/scsi/fcoe/libfcoe.c
+++ b/drivers/scsi/fcoe/libfcoe.c
@@ -633,7 +633,7 @@ int fcoe_percpu_receive_thread(void *arg)
 		 * it's solicited data, in which case, the FCP layer would
 		 * check it during the copy.
 		 */
-		if (lp->crc_offload)
+		if (lp->crc_offload && skb->ip_summed == CHECKSUM_UNNECESSARY)
 			fr_flags(fp) &= ~FCPHF_CRC_UNCHECKED;
 		else
 			fr_flags(fp) |= FCPHF_CRC_UNCHECKED;

