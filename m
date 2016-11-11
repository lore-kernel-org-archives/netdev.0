From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] vhost/scsi: Remove unused but set variable
Date: Fri, 11 Nov 2016 14:27:10 +0100
Message-ID: <20161111132710.25804-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:56820 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756297AbcKKN1O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:27:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unused but set variable se_tpg in vhost_scsi_nexus_cb() to
fix the following GCC warning when building with 'W=1':

  drivers/vhost/scsi.c:1752:26: warning: variable ‘se_tpg’ set but not used

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/vhost/scsi.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index 6e29d053843d..e2be447752c2 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -1749,7 +1749,6 @@ static int vhost_scsi_nexus_cb(struct se_portal_group *se_tpg,
 static int vhost_scsi_make_nexus(struct vhost_scsi_tpg *tpg,
 				const char *name)
 {
-	struct se_portal_group *se_tpg;
 	struct vhost_scsi_nexus *tv_nexus;
 
 	mutex_lock(&tpg->tv_tpg_mutex);
@@ -1758,7 +1757,6 @@ static int vhost_scsi_make_nexus(struct vhost_scsi_tpg *tpg,
 		pr_debug("tpg->tpg_nexus already exists\n");
 		return -EEXIST;
 	}
-	se_tpg = &tpg->se_tpg;
 
 	tv_nexus = kzalloc(sizeof(struct vhost_scsi_nexus), GFP_KERNEL);
 	if (!tv_nexus) {
-- 
2.11.0.rc0.7.gbe5a750
