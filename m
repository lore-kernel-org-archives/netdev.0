From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] bridge: Allow set bridge ageing time when switchdev disabled
Date: Tue, 29 Mar 2016 18:48:08 +0800
Message-ID: <1459248488-25621-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When NET_SWITCHDEV=n, switchdev_port_attr_set will return -EOPNOTSUPP,
we should ignore this error code and continue to set the ageing time.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/bridge/br_stp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index e234490..9cb7044 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -582,7 +582,7 @@ int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
 	int err;
 
 	err = switchdev_port_attr_set(br->dev, &attr);
-	if (err)
+	if (err && err != -EOPNOTSUPP)
 		return err;
 
 	br->ageing_time = t;
-- 
1.8.3.1
