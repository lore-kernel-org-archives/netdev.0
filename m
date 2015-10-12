From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2 3/4] bridge: vlan: drop unnecessary flush code
Date: Mon, 12 Oct 2015 21:47:04 +0200
Message-ID: <1444679225-7354-4-git-send-email-razor@blackwall.org>
References: <1444679225-7354-1-git-send-email-razor@blackwall.org>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, idosch@mellanox.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37298 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbbJLTrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 15:47:12 -0400
Received: by wijq8 with SMTP id q8so73193417wij.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 12:47:11 -0700 (PDT)
In-Reply-To: <1444679225-7354-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

As Ido Schimmel pointed out the vlan_vid_del() code in nbp_vlan_flush is
unnecessary (and is actually a remnant of the old vlan code) so we can
remove it.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: new patch

 net/bridge/br_vlan.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 4d8a21daf728..573ddfc31fb1 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -973,14 +973,7 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 
 void nbp_vlan_flush(struct net_bridge_port *port)
 {
-	struct net_bridge_vlan_group *vg;
-	struct net_bridge_vlan *vlan;
-
 	ASSERT_RTNL();
 
-	vg = nbp_vlan_group(port);
-	list_for_each_entry(vlan, &vg->vlan_list, vlist)
-		vlan_vid_del(port->dev, port->br->vlan_proto, vlan->vid);
-
-	__vlan_flush(vg);
+	__vlan_flush(nbp_vlan_group(port));
 }
-- 
2.4.3
