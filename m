From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: switchdev: ignore unsupported bridge flags
Date: Tue, 23 Jun 2015 10:26:04 -0400
Message-ID: <1435069564-10241-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: sfeldma@gmail.com, Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

switchdev_port_bridge_getlink() queries SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS
attributes, but a driver doesn't need to implement this in order to get
bridge link information.

So error out only on errors different than -EOPNOTSUPP.

(This is a follow-up patch for 7d4f8d8.)

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/switchdev/switchdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index f01d340..84f77a0 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -532,7 +532,7 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	int err;
 
 	err = switchdev_port_attr_get(dev, &attr);
-	if (err)
+	if (err && err != -EOPNOTSUPP)
 		return err;
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
-- 
2.4.4
