From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next] bnx2x: fill in sane dump flag information
Date: Mon,  1 Jul 2013 17:23:20 +0200
Message-ID: <1372692200-31078-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org, Miriam Shitrit <miris@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753801Ab3GAPXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 11:23:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x did not set dump->version in its .get_dump_flag() method.
Let's set it to BNX2X_DUMP_VERSION. It's not a particularly nice
number (0x50acff01 currently), but at least it's something
deterministic.

dump->flag should report the value previously set using ethtool -W.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 10b52b0..8f96442 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -972,12 +972,12 @@ static int bnx2x_get_dump_flag(struct net_device *dev,
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
+	dump->version = BNX2X_DUMP_VERSION;
+	dump->flag = bp->dump_preset_idx;
 	/* Calculate the requested preset idx length */
 	dump->len = bnx2x_get_preset_regs_len(dev, bp->dump_preset_idx);
 	DP(BNX2X_MSG_ETHTOOL, "Get dump preset %d length=%d\n",
 	   bp->dump_preset_idx, dump->len);
-
-	dump->flag = ETHTOOL_GET_DUMP_DATA;
 	return 0;
 }
 
-- 
1.8.1.4
