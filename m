From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/2] vhost/scsi: Improve a size determination in four
 functions
Date: Sat, 20 May 2017 16:31:13 +0200
Message-ID: <68e78c4b-9b18-7607-f8c8-327fdd51f20b@users.sourceforge.net>
References: <bafa65e4-08fe-efdb-d836-7657e8a64749@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: kvm@vger.kernel.org, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <bafa65e4-08fe-efdb-d836-7657e8a64749@users.sourceforge.net>
Content-Language: en-GB
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 20 May 2017 13:48:44 +0200

Replace the specification of four data structures by pointer dereferences
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/vhost/scsi.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index fd6c8b66f06f..650533916c19 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -597,8 +597,7 @@ vhost_scsi_get_tag(struct vhost_virtqueue *vq, struct vhost_scsi_tpg *tpg,
 	sg = cmd->tvc_sgl;
 	prot_sg = cmd->tvc_prot_sgl;
 	pages = cmd->tvc_upages;
-	memset(cmd, 0, sizeof(struct vhost_scsi_cmd));
-
+	memset(cmd, 0, sizeof(*cmd));
 	cmd->tvc_sgl = sg;
 	cmd->tvc_prot_sgl = prot_sg;
 	cmd->tvc_upages = pages;
@@ -1757,5 +1756,5 @@ static int vhost_scsi_make_nexus(struct vhost_scsi_tpg *tpg,
 		return -EEXIST;
 	}
 
-	tv_nexus = kzalloc(sizeof(struct vhost_scsi_nexus), GFP_KERNEL);
+	tv_nexus = kzalloc(sizeof(*tv_nexus), GFP_KERNEL);
 	if (!tv_nexus) {
@@ -1958,5 +1957,5 @@ vhost_scsi_make_tpg(struct se_wwn *wwn,
 	if (kstrtou16(name + 5, 10, &tpgt) || tpgt >= VHOST_SCSI_MAX_TARGET)
 		return ERR_PTR(-EINVAL);
 
-	tpg = kzalloc(sizeof(struct vhost_scsi_tpg), GFP_KERNEL);
+	tpg = kzalloc(sizeof(*tpg), GFP_KERNEL);
 	if (!tpg) {
@@ -2012,5 +2011,5 @@ vhost_scsi_make_tport(struct target_fabric_configfs *tf,
 	/* if (vhost_scsi_parse_wwn(name, &wwpn, 1) < 0)
 		return ERR_PTR(-EINVAL); */
 
-	tport = kzalloc(sizeof(struct vhost_scsi_tport), GFP_KERNEL);
+	tport = kzalloc(sizeof(*tport), GFP_KERNEL);
 	if (!tport) {
-- 
2.13.0
