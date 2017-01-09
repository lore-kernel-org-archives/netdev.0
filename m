From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] vhost: scsi: constify target_core_fabric_ops structures
Date: Mon,  9 Jan 2017 20:51:02 +0530
Message-ID: <1483975262-1260-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, mst@redhat.com, jasowang@redhat.com,
        kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare target_core_fabric_ops strucrues as const as they are only
passed as an argument to the functions target_register_template and 
target_unregister_template. The arguments are of type const struct 
target_core_fabric_ops *, so target_core_fabric_ops structures having 
this property can be declared const.
Done using Coccinelle:

@r disable optional_qualifier@
identifier i;
position p;
@@
static struct target_core_fabric_ops i@p={...};

@ok@
position p;
identifier r.i;
@@
(
target_register_template(&i@p)
|
target_unregister_template(&i@p)
)
@bad@
position p!={r.p,ok.p};
identifier r.i;
@@
i@p

@depends on !bad disable optional_qualifier@
identifier r.i;
@@
+const
struct target_core_fabric_ops i;

File size before: drivers/vhost/scsi.o
   text	   data	    bss	    dec	    hex	filename
  18063	   2985	     40	  21088	   5260	drivers/vhost/scsi.o

File size after: drivers/vhost/scsi.o
   text	   data	    bss	    dec	    hex	filename
  18479	   2601	     40	  21120	   5280	drivers/vhost/scsi.o

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/vhost/scsi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index 253310c..620366d 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -2087,7 +2087,7 @@ static void vhost_scsi_drop_tport(struct se_wwn *wwn)
 	NULL,
 };
 
-static struct target_core_fabric_ops vhost_scsi_ops = {
+static const struct target_core_fabric_ops vhost_scsi_ops = {
 	.module				= THIS_MODULE,
 	.name				= "vhost",
 	.get_fabric_name		= vhost_scsi_get_fabric_name,
-- 
1.9.1
