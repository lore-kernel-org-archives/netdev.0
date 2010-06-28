From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -next] bnx2x: fail when try to setup unsupported features
Date: Mon, 28 Jun 2010 11:28:11 +0200
Message-ID: <20100628112811.29881285@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55035 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992Ab0F1J2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 05:28:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/bnx2x_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 57ff5b3..0809f6c 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10982,6 +10982,9 @@ static int bnx2x_set_flags(struct net_device *dev, u32 data)
 	int changed = 0;
 	int rc = 0;
 
+	if (data & ~(ETH_FLAG_LRO | ETH_FLAG_RXHASH))
+		return -EOPNOTSUPP;
+
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
 		return -EAGAIN;
-- 
1.5.5.6

