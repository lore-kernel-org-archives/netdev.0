From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] qlogic: qlcnic_sysfs: constify bin_attribute structures
Date: Wed, 22 Feb 2017 00:11:17 +0530
Message-ID: <1487702477-14025-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, harish.patil@cavium.com,
        manish.chopra@cavium.com, Dept-GELinuxNICDev@cavium.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33700 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751431AbdBUSl3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:41:29 -0500
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
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index ccbb045..73027a6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -1192,56 +1192,56 @@ static ssize_t qlcnic_83xx_sysfs_flash_write_handler(struct file *filp,
 	.store = qlcnic_store_beacon,
 };
 
-static struct bin_attribute bin_attr_crb = {
+static const struct bin_attribute bin_attr_crb = {
 	.attr = {.name = "crb", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
 	.read = qlcnic_sysfs_read_crb,
 	.write = qlcnic_sysfs_write_crb,
 };
 
-static struct bin_attribute bin_attr_mem = {
+static const struct bin_attribute bin_attr_mem = {
 	.attr = {.name = "mem", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
 	.read = qlcnic_sysfs_read_mem,
 	.write = qlcnic_sysfs_write_mem,
 };
 
-static struct bin_attribute bin_attr_npar_config = {
+static const struct bin_attribute bin_attr_npar_config = {
 	.attr = {.name = "npar_config", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
 	.read = qlcnic_sysfs_read_npar_config,
 	.write = qlcnic_sysfs_write_npar_config,
 };
 
-static struct bin_attribute bin_attr_pci_config = {
+static const struct bin_attribute bin_attr_pci_config = {
 	.attr = {.name = "pci_config", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
 	.read = qlcnic_sysfs_read_pci_config,
 	.write = NULL,
 };
 
-static struct bin_attribute bin_attr_port_stats = {
+static const struct bin_attribute bin_attr_port_stats = {
 	.attr = {.name = "port_stats", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
 	.read = qlcnic_sysfs_get_port_stats,
 	.write = qlcnic_sysfs_clear_port_stats,
 };
 
-static struct bin_attribute bin_attr_esw_stats = {
+static const struct bin_attribute bin_attr_esw_stats = {
 	.attr = {.name = "esw_stats", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
 	.read = qlcnic_sysfs_get_esw_stats,
 	.write = qlcnic_sysfs_clear_esw_stats,
 };
 
-static struct bin_attribute bin_attr_esw_config = {
+static const struct bin_attribute bin_attr_esw_config = {
 	.attr = {.name = "esw_config", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
 	.read = qlcnic_sysfs_read_esw_config,
 	.write = qlcnic_sysfs_write_esw_config,
 };
 
-static struct bin_attribute bin_attr_pm_config = {
+static const struct bin_attribute bin_attr_pm_config = {
 	.attr = {.name = "pm_config", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
 	.read = qlcnic_sysfs_read_pm_config,
-- 
1.9.1
