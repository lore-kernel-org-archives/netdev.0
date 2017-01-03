From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 09/27] cxgb4: use __vlan_hwaccel helpers
Date: Tue,  3 Jan 2017 21:52:35 +0100 (CET)
Message-ID: <fb8110a06b9e2b2cb3eda1d681d0a03eab32f815.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Steve Wise <swise@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:34718 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935899AbdACUwk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 15:52:40 -0500
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also initializes vlan_proto field.

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/infiniband/hw/cxgb4/cm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index f1510cc76d2d..66a3d39b3d54 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -3899,7 +3899,7 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 	} else {
 		vlan_eh = (struct vlan_ethhdr *)(req + 1);
 		iph = (struct iphdr *)(vlan_eh + 1);
-		skb->vlan_tci = ntohs(cpl->vlan);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(cpl->vlan));
 	}
 
 	if (iph->version != 0x4)
-- 
2.11.0
