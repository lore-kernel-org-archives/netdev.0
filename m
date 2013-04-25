From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next 1/2] vxlan: introduce vxlan_rdst_append
Date: Thu, 25 Apr 2013 14:03:48 +0300
Message-ID: <1366887829-3950-2-git-send-email-mike.rapoport@ravellosystems.com>
References: <1366887829-3950-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog107.obsmtp.com ([74.125.245.82]:52871 "HELO
	na3sys010aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757916Ab3DYLEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 07:04:11 -0400
Received: by mail-wi0-f200.google.com with SMTP id m6so3888494wiv.3
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 04:04:09 -0700 (PDT)
In-Reply-To: <1366887829-3950-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to allow remotes list management for both FDB entries and default
destinations

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index be42e00..8963a83 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -387,14 +387,13 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 	return NULL;
 }
 
-/* Add/update destinations for multicast */
-static int vxlan_fdb_append(struct vxlan_fdb *f, union vxlan_addr *ip,
-			    __u32 port, __u32 vni, __u32 ifindex)
+static int vxlan_rdst_append(struct vxlan_rdst *rdst, union vxlan_addr *ip,
+			     __u32 port, __u32 vni, __u32 ifindex)
 {
 	struct vxlan_rdst *rd_prev, *rd;
 
 	rd_prev = NULL;
-	for (rd = &f->remote; rd; rd = rd->remote_next) {
+	for (rd = rdst; rd; rd = rd->remote_next) {
 		if (vxlan_addr_equal(&rd->remote_ip, ip) &&
 		    rd->remote_port == port &&
 		    rd->remote_vni == vni &&
@@ -414,6 +413,13 @@ static int vxlan_fdb_append(struct vxlan_fdb *f, union vxlan_addr *ip,
 	return 1;
 }
 
+/* Add/update destinations for multicast */
+static int vxlan_fdb_append(struct vxlan_fdb *f, union vxlan_addr *ip,
+			    __u32 port, __u32 vni, __u32 ifindex)
+{
+	return vxlan_rdst_append(&f->remote, ip, port, vni, ifindex);
+}
+
 /* Add new entry to forwarding table -- assumes lock held */
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			    const u8 *mac, union vxlan_addr *ip,
-- 
1.8.1.5
