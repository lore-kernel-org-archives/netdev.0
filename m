From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 08/10] vxlan:  use initializer for dummy structures
Date: Tue,  4 Jun 2013 21:24:12 -0700
Message-ID: <1370406254-6341-8-git-send-email-stephen@networkplumber.org>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:51670 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117Ab3FEEYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 00:24:31 -0400
Received: by mail-pb0-f50.google.com with SMTP id wy17so1213810pbc.37
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 21:24:30 -0700 (PDT)
In-Reply-To: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the notification code, a couple of places build fdb entries on
the stack, use structure initialization instead and fix formatting.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |   21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 57b5274..664381a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -305,14 +305,13 @@ errout:
 static void vxlan_ip_miss(struct net_device *dev, __be32 ipa)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_fdb f;
-	struct vxlan_rdst remote;
-
-	memset(&f, 0, sizeof f);
-	f.state = NUD_STALE;
-
-	remote.remote_ip = ipa; /* goes to NDA_DST */
-	remote.remote_vni = VXLAN_N_VID;
+	struct vxlan_fdb f = {
+		.state = NUD_STALE,
+	};
+	struct vxlan_rdst remote = {
+		.remote_ip = ipa, /* goes to NDA_DST */
+		.remote_vni = VXLAN_N_VID,
+	};
 
 	INIT_LIST_HEAD(&f.remotes);
 	list_add_rcu(&remote.list, &f.remotes);
@@ -322,11 +321,11 @@ static void vxlan_ip_miss(struct net_device *dev, __be32 ipa)
 
 static void vxlan_fdb_miss(struct vxlan_dev *vxlan, const u8 eth_addr[ETH_ALEN])
 {
-	struct vxlan_fdb	f;
+	struct vxlan_fdb f = {
+		.state = NUD_STALE,
+	};
 
-	memset(&f, 0, sizeof f);
 	INIT_LIST_HEAD(&f.remotes);
-	f.state = NUD_STALE;
 	memcpy(f.eth_addr, eth_addr, ETH_ALEN);
 
 	vxlan_fdb_notify(vxlan, &f, RTM_GETNEIGH);
-- 
1.7.10.4
