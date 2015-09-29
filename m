From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/6] net: switchdev: remove dev in port_vlan_dump_put
Date: Tue, 29 Sep 2015 11:04:09 -0400
Message-ID: <1443539054-25997-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1443539054-25997-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443539054-25997-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The static switchdev_port_vlan_dump_put function don't need the
net_device parameter, so remove it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/switchdev/switchdev.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 00ee547..56d34ed 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -484,8 +484,7 @@ struct switchdev_vlan_dump {
 	u16 end;
 };
 
-static int switchdev_port_vlan_dump_put(struct net_device *dev,
-					struct switchdev_vlan_dump *dump)
+static int switchdev_port_vlan_dump_put(struct switchdev_vlan_dump *dump)
 {
 	struct bridge_vlan_info vinfo;
 
@@ -531,7 +530,7 @@ static int switchdev_port_vlan_dump_cb(struct net_device *dev,
 		for (dump->begin = dump->end = vlan->vid_begin;
 		     dump->begin <= vlan->vid_end;
 		     dump->begin++, dump->end++) {
-			err = switchdev_port_vlan_dump_put(dev, dump);
+			err = switchdev_port_vlan_dump_put(dump);
 			if (err)
 				return err;
 		}
@@ -543,7 +542,7 @@ static int switchdev_port_vlan_dump_cb(struct net_device *dev,
 				/* prepend */
 				dump->begin = vlan->vid_begin;
 			} else {
-				err = switchdev_port_vlan_dump_put(dev, dump);
+				err = switchdev_port_vlan_dump_put(dump);
 				dump->flags = vlan->flags;
 				dump->begin = vlan->vid_begin;
 				dump->end = vlan->vid_end;
@@ -555,7 +554,7 @@ static int switchdev_port_vlan_dump_cb(struct net_device *dev,
 				/* append */
 				dump->end = vlan->vid_end;
 			} else {
-				err = switchdev_port_vlan_dump_put(dev, dump);
+				err = switchdev_port_vlan_dump_put(dump);
 				dump->flags = vlan->flags;
 				dump->begin = vlan->vid_begin;
 				dump->end = vlan->vid_end;
@@ -588,7 +587,7 @@ static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
 			goto err_out;
 		if (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)
 			/* last one */
-			err = switchdev_port_vlan_dump_put(dev, &dump);
+			err = switchdev_port_vlan_dump_put(&dump);
 	}
 
 err_out:
-- 
2.5.3
