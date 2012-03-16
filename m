From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 1/2] bnx2x: fix a crash on corrupt firmware file
Date: Fri, 16 Mar 2012 01:08:28 +0100
Message-ID: <1331856509-9159-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <yuvalmin@broadcom.com>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2086 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161705Ab2CPAIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 20:08:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the requested firmware is deemed corrupt and then released, reset the
pointer to NULL in order to avoid double-freeing it in
bnx2x_release_firmware() or dereferencing it in bnx2x_init_firmware().

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2545213..00ff62f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10901,6 +10901,7 @@ init_ops_alloc_err:
 	kfree(bp->init_data);
 request_firmware_exit:
 	release_firmware(bp->firmware);
+	bp->firmware = NULL;
 
 	return rc;
 }
-- 
1.7.7.6
