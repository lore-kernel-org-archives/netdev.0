From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] bridge: rename fdb_*_hw to fdb_*_hw_addr to avoid confusion
Date: Sun,  9 Nov 2014 17:40:16 +0100
Message-ID: <1415551216-2239-1-git-send-email-jiri@resnulli.us>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:40468 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbaKIQkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 11:40:22 -0500
Received: by mail-wg0-f48.google.com with SMTP id m15so7211213wgh.7
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 08:40:21 -0800 (PST)
In-Reply-To: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current name might seem that this actually offloads the fdb entry to
hw. So rename it to clearly present that this for hardware address
addition/removal.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/bridge/br_fdb.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index e02d21b..3886f84 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -91,7 +91,7 @@ static void fdb_rcu_free(struct rcu_head *head)
  * are then updated with the new information.
  * Called under RTNL.
  */
-static void fdb_add_hw(struct net_bridge *br, const unsigned char *addr)
+static void fdb_add_hw_addr(struct net_bridge *br, const unsigned char *addr)
 {
 	int err;
 	struct net_bridge_port *p;
@@ -119,7 +119,7 @@ undo:
  * the ports with needed information.
  * Called under RTNL.
  */
-static void fdb_del_hw(struct net_bridge *br, const unsigned char *addr)
+static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
 {
 	struct net_bridge_port *p;
 
@@ -134,7 +134,7 @@ static void fdb_del_hw(struct net_bridge *br, const unsigned char *addr)
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 {
 	if (f->is_static) {
-		fdb_del_hw(br, f->addr.addr);
+		fdb_del_hw_addr(br, f->addr.addr);
 		if (f->dst)
 			netdev_sw_port_fdb_del(f->dst->dev,
 					       f->addr.addr, f->vlan_id);
@@ -519,7 +519,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		return -ENOMEM;
 
 	fdb->is_local = fdb->is_static = 1;
-	fdb_add_hw(br, addr);
+	fdb_add_hw_addr(br, addr);
 	fdb_notify(br, fdb, RTM_NEWNEIGH);
 	return 0;
 }
@@ -759,21 +759,21 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 			fdb->is_local = 1;
 			if (!fdb->is_static) {
 				fdb->is_static = 1;
-				fdb_add_hw(br, addr);
+				fdb_add_hw_addr(br, addr);
 				netdev_sw_port_fdb_add(source->dev, addr, vid);
 			}
 		} else if (state & NUD_NOARP) {
 			fdb->is_local = 0;
 			if (!fdb->is_static) {
 				fdb->is_static = 1;
-				fdb_add_hw(br, addr);
+				fdb_add_hw_addr(br, addr);
 				netdev_sw_port_fdb_add(source->dev, addr, vid);
 			}
 		} else {
 			fdb->is_local = 0;
 			if (fdb->is_static) {
 				fdb->is_static = 0;
-				fdb_del_hw(br, addr);
+				fdb_del_hw_addr(br, addr);
 				netdev_sw_port_fdb_del(source->dev, addr, vid);
 			}
 		}
-- 
1.9.3
