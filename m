From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] qlogic: netxen: constify bin_attribute structures
Date: Wed, 22 Feb 2017 00:17:48 +0530
Message-ID: <1487702868-14161-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, rahul.verma@cavium.com,
        manish.chopra@cavium.com, Dept-GELinuxNICDev@cavium.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34560 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752048AbdBUSsB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:48:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declare bin_attribute structures as const as they are only passed as an
arguments to the functions device_remove_bin_file and
device_create_bin_file. These function arguments are of type const, so
bin_attribute structures having this property can be made const too.
Done using Coccinelle:

@r1 disable optional_qualifier @
identifier i;
position p;
@@
static struct bin_attribute i@p = {...};

@ok1@
identifier r1.i;
position p,p1;
@@
(
device_remove_bin_file(...,&i@p)
|
device_create_bin_file(..., &i@p1)
)

@bad@
position p!={r1.p,ok1.p,ok1.p1};
identifier r1.i;
@@
i@p

@depends on !bad disable optional_qualifier@
identifier r1.i;
@@
+const
struct bin_attribute i;

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 561fb94..ee5376e 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -3007,14 +3007,14 @@ static ssize_t netxen_sysfs_write_mem(struct file *filp, struct kobject *kobj,
 }
 
 
-static struct bin_attribute bin_attr_crb = {
+static const struct bin_attribute bin_attr_crb = {
 	.attr = {.name = "crb", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
 	.read = netxen_sysfs_read_crb,
 	.write = netxen_sysfs_write_crb,
 };
 
-static struct bin_attribute bin_attr_mem = {
+static const struct bin_attribute bin_attr_mem = {
 	.attr = {.name = "mem", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
 	.read = netxen_sysfs_read_mem,
@@ -3143,7 +3143,7 @@ static ssize_t netxen_sysfs_write_mem(struct file *filp, struct kobject *kobj,
 
 }
 
-static struct bin_attribute bin_attr_dimm = {
+static const struct bin_attribute bin_attr_dimm = {
 	.attr = { .name = "dimm", .mode = (S_IRUGO | S_IWUSR) },
 	.size = sizeof(struct netxen_dimm_cfg),
 	.read = netxen_sysfs_read_dimm,
-- 
1.9.1
