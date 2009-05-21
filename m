From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next] cxgb3: set phy's mdio dev before the phy init
	sequence
Date: Wed, 20 May 2009 18:56:02 -0700
Message-ID: <20090521015602.1905.98758.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10088 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754277AbZEUB4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 21:56:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

mdio's dev field needs to be set before mdio ops occur.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index c8a865a..7e502ff 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3864,11 +3864,11 @@ int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 			return -EINVAL;
 		}
 
+		p->phy.mdio.dev = adapter->port[i];
 		ret = pti->phy_prep(&p->phy, adapter, ai->phy_base_addr + j,
 				    ai->mdio_ops);
 		if (ret)
 			return ret;
-		p->phy.mdio.dev = adapter->port[i];
 		mac_prep(&p->mac, adapter, j);
 
 		/*

