From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] infiniband: use %p6 for printing message ids
Date: Tue, 28 Oct 2008 14:38:21 -0700
Message-ID: <1225229901.11483.58.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:65322 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbYJ1VkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 17:40:07 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2836662wfd.4
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 14:40:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/infiniband/core/sysfs.c         |   10 +---------
 drivers/infiniband/hw/mthca/mthca_mcg.c |   23 ++---------------------
 drivers/infiniband/ulp/srp/ib_srp.c     |   31 ++++---------------------------
 drivers/net/mlx4/mcg.c                  |   23 ++---------------------
 4 files changed, 9 insertions(+), 78 deletions(-)

diff --git a/drivers/infiniband/core/sysfs.c b/drivers/infiniband/core/sysfs.c
index 4d10421..e985193 100644
--- a/drivers/infiniband/core/sysfs.c
+++ b/drivers/infiniband/core/sysfs.c
@@ -262,15 +262,7 @@ static ssize_t show_port_gid(struct ib_port *p, struct port_attribute *attr,
 	if (ret)
 		return ret;
 
-	return sprintf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
-		       be16_to_cpu(((__be16 *) gid.raw)[0]),
-		       be16_to_cpu(((__be16 *) gid.raw)[1]),
-		       be16_to_cpu(((__be16 *) gid.raw)[2]),
-		       be16_to_cpu(((__be16 *) gid.raw)[3]),
-		       be16_to_cpu(((__be16 *) gid.raw)[4]),
-		       be16_to_cpu(((__be16 *) gid.raw)[5]),
-		       be16_to_cpu(((__be16 *) gid.raw)[6]),
-		       be16_to_cpu(((__be16 *) gid.raw)[7]));
+	return sprintf(buf, "%p6\n", gid.raw);
 }
 
 static ssize_t show_port_pkey(struct ib_port *p, struct port_attribute *attr,
diff --git a/drivers/infiniband/hw/mthca/mthca_mcg.c b/drivers/infiniband/hw/mthca/mthca_mcg.c
index 3f5f948..693bed0 100644
--- a/drivers/infiniband/hw/mthca/mthca_mcg.c
+++ b/drivers/infiniband/hw/mthca/mthca_mcg.c
@@ -87,17 +87,7 @@ static int find_mgm(struct mthca_dev *dev,
 	}
 
 	if (0)
-		mthca_dbg(dev, "Hash for %04x:%04x:%04x:%04x:"
-			  "%04x:%04x:%04x:%04x is %04x\n",
-			  be16_to_cpu(((__be16 *) gid)[0]),
-			  be16_to_cpu(((__be16 *) gid)[1]),
-			  be16_to_cpu(((__be16 *) gid)[2]),
-			  be16_to_cpu(((__be16 *) gid)[3]),
-			  be16_to_cpu(((__be16 *) gid)[4]),
-			  be16_to_cpu(((__be16 *) gid)[5]),
-			  be16_to_cpu(((__be16 *) gid)[6]),
-			  be16_to_cpu(((__be16 *) gid)[7]),
-			  *hash);
+		mthca_dbg(dev, "Hash for %p6 is %04x\n", gid, *hash);
 
 	*index = *hash;
 	*prev  = -1;
@@ -264,16 +254,7 @@ int mthca_multicast_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 		goto out;
 
 	if (index == -1) {
-		mthca_err(dev, "MGID %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x "
-			  "not found\n",
-			  be16_to_cpu(((__be16 *) gid->raw)[0]),
-			  be16_to_cpu(((__be16 *) gid->raw)[1]),
-			  be16_to_cpu(((__be16 *) gid->raw)[2]),
-			  be16_to_cpu(((__be16 *) gid->raw)[3]),
-			  be16_to_cpu(((__be16 *) gid->raw)[4]),
-			  be16_to_cpu(((__be16 *) gid->raw)[5]),
-			  be16_to_cpu(((__be16 *) gid->raw)[6]),
-			  be16_to_cpu(((__be16 *) gid->raw)[7]));
+		mthca_err(dev, "MGID %p6 not found\n", gid->raw);
 		err = -EINVAL;
 		goto out;
 	}
diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index 5b8b533..bc82531 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -1514,15 +1514,7 @@ static ssize_t show_dgid(struct device *dev, struct device_attribute *attr,
 	    target->state == SRP_TARGET_REMOVED)
 		return -ENODEV;
 
-	return sprintf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
-		       be16_to_cpu(((__be16 *) target->path.dgid.raw)[0]),
-		       be16_to_cpu(((__be16 *) target->path.dgid.raw)[1]),
-		       be16_to_cpu(((__be16 *) target->path.dgid.raw)[2]),
-		       be16_to_cpu(((__be16 *) target->path.dgid.raw)[3]),
-		       be16_to_cpu(((__be16 *) target->path.dgid.raw)[4]),
-		       be16_to_cpu(((__be16 *) target->path.dgid.raw)[5]),
-		       be16_to_cpu(((__be16 *) target->path.dgid.raw)[6]),
-		       be16_to_cpu(((__be16 *) target->path.dgid.raw)[7]));
+	return sprintf(buf, "%p6\n", target->path.dgid.raw);
 }
 
 static ssize_t show_orig_dgid(struct device *dev,
@@ -1534,15 +1526,7 @@ static ssize_t show_orig_dgid(struct device *dev,
 	    target->state == SRP_TARGET_REMOVED)
 		return -ENODEV;
 
-	return sprintf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
-		       be16_to_cpu(target->orig_dgid[0]),
-		       be16_to_cpu(target->orig_dgid[1]),
-		       be16_to_cpu(target->orig_dgid[2]),
-		       be16_to_cpu(target->orig_dgid[3]),
-		       be16_to_cpu(target->orig_dgid[4]),
-		       be16_to_cpu(target->orig_dgid[5]),
-		       be16_to_cpu(target->orig_dgid[6]),
-		       be16_to_cpu(target->orig_dgid[7]));
+	return sprintf(buf, "%p6\n", target->orig_dgid);
 }
 
 static ssize_t show_zero_req_lim(struct device *dev,
@@ -1883,19 +1867,12 @@ static ssize_t srp_create_target(struct device *dev,
 
 	shost_printk(KERN_DEBUG, target->scsi_host, PFX
 		     "new target: id_ext %016llx ioc_guid %016llx pkey %04x "
-		     "service_id %016llx dgid %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
+		     "service_id %016llx dgid %p6\n",
 	       (unsigned long long) be64_to_cpu(target->id_ext),
 	       (unsigned long long) be64_to_cpu(target->ioc_guid),
 	       be16_to_cpu(target->path.pkey),
 	       (unsigned long long) be64_to_cpu(target->service_id),
-	       (int) be16_to_cpu(*(__be16 *) &target->path.dgid.raw[0]),
-	       (int) be16_to_cpu(*(__be16 *) &target->path.dgid.raw[2]),
-	       (int) be16_to_cpu(*(__be16 *) &target->path.dgid.raw[4]),
-	       (int) be16_to_cpu(*(__be16 *) &target->path.dgid.raw[6]),
-	       (int) be16_to_cpu(*(__be16 *) &target->path.dgid.raw[8]),
-	       (int) be16_to_cpu(*(__be16 *) &target->path.dgid.raw[10]),
-	       (int) be16_to_cpu(*(__be16 *) &target->path.dgid.raw[12]),
-	       (int) be16_to_cpu(*(__be16 *) &target->path.dgid.raw[14]));
+	       target->path.dgid.raw);
 
 	ret = srp_create_target_ib(target);
 	if (ret)
diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index 592c01a..6f79e84 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -118,17 +118,7 @@ static int find_mgm(struct mlx4_dev *dev,
 		return err;
 
 	if (0)
-		mlx4_dbg(dev, "Hash for %04x:%04x:%04x:%04x:"
-			  "%04x:%04x:%04x:%04x is %04x\n",
-			  be16_to_cpu(((__be16 *) gid)[0]),
-			  be16_to_cpu(((__be16 *) gid)[1]),
-			  be16_to_cpu(((__be16 *) gid)[2]),
-			  be16_to_cpu(((__be16 *) gid)[3]),
-			  be16_to_cpu(((__be16 *) gid)[4]),
-			  be16_to_cpu(((__be16 *) gid)[5]),
-			  be16_to_cpu(((__be16 *) gid)[6]),
-			  be16_to_cpu(((__be16 *) gid)[7]),
-			  *hash);
+		mlx4_dbg(dev, "Hash for %p6 is %04x\n", gid, *hash);
 
 	*index = *hash;
 	*prev  = -1;
@@ -277,16 +267,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 		goto out;
 
 	if (index == -1) {
-		mlx4_err(dev, "MGID %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x "
-			  "not found\n",
-			  be16_to_cpu(((__be16 *) gid)[0]),
-			  be16_to_cpu(((__be16 *) gid)[1]),
-			  be16_to_cpu(((__be16 *) gid)[2]),
-			  be16_to_cpu(((__be16 *) gid)[3]),
-			  be16_to_cpu(((__be16 *) gid)[4]),
-			  be16_to_cpu(((__be16 *) gid)[5]),
-			  be16_to_cpu(((__be16 *) gid)[6]),
-			  be16_to_cpu(((__be16 *) gid)[7]));
+		mlx4_err(dev, "MGID %p6 not found\n", gid);
 		err = -EINVAL;
 		goto out;
 	}
-- 
1.6.0.3.729.g6ea410



