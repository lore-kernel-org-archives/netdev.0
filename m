From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v3 1/2] vxlan: introduce vxlan_rdst_append
Date: Wed, 29 May 2013 13:00:15 +0300
Message-ID: <1369821617-29098-2-git-send-email-mike.rapoport@ravellosystems.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Thomas Graf <tgraf@suug.ch>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog107.obsmtp.com ([74.125.245.82]:59247 "HELO
	na3sys010aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965107Ab3E2KBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 06:01:00 -0400
Received: by mail-ea0-f177.google.com with SMTP id q14so5172428eaj.22
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 03:00:58 -0700 (PDT)
In-Reply-To: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to allow remotes list management for both FDB entries and default
destinations

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8111565..5a2cf2f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -366,14 +366,13 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 	return f;
 }
 
-/* Add/update destinations for multicast */
-static int vxlan_fdb_append(struct vxlan_fdb *f,
-			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
+static int vxlan_rdst_append(struct vxlan_rdst *rdst, __be32 ip, __be16 port,
+			     __u32 vni, __u32 ifindex)
 {
 	struct vxlan_rdst *rd_prev, *rd;
 
 	rd_prev = NULL;
-	for (rd = &f->remote; rd; rd = rd->remote_next) {
+	for (rd = rdst; rd; rd = rd->remote_next) {
 		if (rd->remote_ip == ip &&
 		    rd->remote_port == port &&
 		    rd->remote_vni == vni &&
@@ -393,6 +392,13 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 	return 1;
 }
 
+/* Add/update destinations for multicast */
+static int vxlan_fdb_append(struct vxlan_fdb *f,
+			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
+{
+	return vxlan_rdst_append(&f->remote, ip, port, vni, ifindex);
+}
+
 /* Add new entry to forwarding table -- assumes lock held */
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			    const u8 *mac, __be32 ip,
-- 
1.8.1.5
