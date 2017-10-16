From: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 03/15] target: make config_item_type const
Date: Mon, 16 Oct 2017 17:18:42 +0200
Message-ID: <1508167134-6243-4-git-send-email-bhumirks@gmail.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: julia.lawall-L2FTfq7BK8M@public.gmane.org, rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org, lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        knaack.h-Mmb7MZpHnFY@public.gmane.org, lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org, pmeerw-jW+XmwGofnusTnJN9+BGXg@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hch-jcswGhMUV9g@public.gmane.org, sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org,
        kishon-l0cyMroinI0@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org,
        balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
        laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org, jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org,
        ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mfasheh-rOS7oXVqrJRBDgjK7y7TUQ@public.gmane.org,
        linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-iio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        cluster-devel@redh
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508167134-6243-1-git-send-email-bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make these structures const as they are either passed to the functions
having the argument as const or stored as a reference in the "ci_type"
const field of a config_item structure.

Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
* Changes in v2- Combine all the followup patches and the constification
patches into a series.

 drivers/target/iscsi/iscsi_target_stat.c | 12 ++++++------
 drivers/target/target_core_configfs.c    | 14 +++++++-------
 drivers/target/target_core_stat.c        | 16 ++++++++--------
 include/target/iscsi/iscsi_target_stat.h | 12 ++++++------
 4 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/target/iscsi/iscsi_target_stat.c b/drivers/target/iscsi/iscsi_target_stat.c
index 411cb26..df0a398 100644
--- a/drivers/target/iscsi/iscsi_target_stat.c
+++ b/drivers/target/iscsi/iscsi_target_stat.c
@@ -187,7 +187,7 @@ static ssize_t iscsi_stat_instance_version_show(struct config_item *item,
 	NULL,
 };
 
-struct config_item_type iscsi_stat_instance_cit = {
+const struct config_item_type iscsi_stat_instance_cit = {
 	.ct_attrs		= iscsi_stat_instance_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -249,7 +249,7 @@ static ssize_t iscsi_stat_sess_err_format_errors_show(struct config_item *item,
 	NULL,
 };
 
-struct config_item_type iscsi_stat_sess_err_cit = {
+const struct config_item_type iscsi_stat_sess_err_cit = {
 	.ct_attrs		= iscsi_stat_sess_err_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -390,7 +390,7 @@ static ssize_t iscsi_stat_tgt_attr_fail_intr_addr_show(struct config_item *item,
 	NULL,
 };
 
-struct config_item_type iscsi_stat_tgt_attr_cit = {
+const struct config_item_type iscsi_stat_tgt_attr_cit = {
 	.ct_attrs		= iscsi_stat_tgt_attr_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -522,7 +522,7 @@ static ssize_t iscsi_stat_login_negotiate_fails_show(struct config_item *item,
 	NULL,
 };
 
-struct config_item_type iscsi_stat_login_cit = {
+const struct config_item_type iscsi_stat_login_cit = {
 	.ct_attrs		= iscsi_stat_login_stats_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -579,7 +579,7 @@ static ssize_t iscsi_stat_logout_abnormal_logouts_show(struct config_item *item,
 	NULL,
 };
 
-struct config_item_type iscsi_stat_logout_cit = {
+const struct config_item_type iscsi_stat_logout_cit = {
 	.ct_attrs		= iscsi_stat_logout_stats_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -801,7 +801,7 @@ static ssize_t iscsi_stat_sess_conn_timeout_errors_show(
 	NULL,
 };
 
-struct config_item_type iscsi_stat_sess_cit = {
+const struct config_item_type iscsi_stat_sess_cit = {
 	.ct_attrs		= iscsi_stat_sess_stats_attrs,
 	.ct_owner		= THIS_MODULE,
 };
diff --git a/drivers/target/target_core_configfs.c b/drivers/target/target_core_configfs.c
index 7e87d95..bd87cc2 100644
--- a/drivers/target/target_core_configfs.c
+++ b/drivers/target/target_core_configfs.c
@@ -307,7 +307,7 @@ static void target_core_deregister_fabric(
 /*
  * Provides Fabrics Groups and Item Attributes for /sys/kernel/config/target/
  */
-static struct config_item_type target_core_fabrics_item = {
+static const struct config_item_type target_core_fabrics_item = {
 	.ct_group_ops	= &target_core_fabric_group_ops,
 	.ct_attrs	= target_core_fabric_item_attrs,
 	.ct_owner	= THIS_MODULE,
@@ -2376,7 +2376,7 @@ static void target_core_alua_lu_gp_release(struct config_item *item)
 	.release		= target_core_alua_lu_gp_release,
 };
 
-static struct config_item_type target_core_alua_lu_gp_cit = {
+static const struct config_item_type target_core_alua_lu_gp_cit = {
 	.ct_item_ops		= &target_core_alua_lu_gp_ops,
 	.ct_attrs		= target_core_alua_lu_gp_attrs,
 	.ct_owner		= THIS_MODULE,
@@ -2434,7 +2434,7 @@ static void target_core_alua_drop_lu_gp(
 	.drop_item		= &target_core_alua_drop_lu_gp,
 };
 
-static struct config_item_type target_core_alua_lu_gps_cit = {
+static const struct config_item_type target_core_alua_lu_gps_cit = {
 	.ct_item_ops		= NULL,
 	.ct_group_ops		= &target_core_alua_lu_gps_group_ops,
 	.ct_owner		= THIS_MODULE,
@@ -2813,7 +2813,7 @@ static void target_core_alua_tg_pt_gp_release(struct config_item *item)
 	.release		= target_core_alua_tg_pt_gp_release,
 };
 
-static struct config_item_type target_core_alua_tg_pt_gp_cit = {
+static const struct config_item_type target_core_alua_tg_pt_gp_cit = {
 	.ct_item_ops		= &target_core_alua_tg_pt_gp_ops,
 	.ct_attrs		= target_core_alua_tg_pt_gp_attrs,
 	.ct_owner		= THIS_MODULE,
@@ -2884,7 +2884,7 @@ static void target_core_alua_drop_tg_pt_gp(
  * core/alua/lu_gps and core/alua/tg_pt_gps that are attached to
  * target_core_alua_cit in target_core_init_configfs() below.
  */
-static struct config_item_type target_core_alua_cit = {
+static const struct config_item_type target_core_alua_cit = {
 	.ct_item_ops		= NULL,
 	.ct_attrs		= NULL,
 	.ct_owner		= THIS_MODULE,
@@ -3105,7 +3105,7 @@ static void target_core_hba_release(struct config_item *item)
 	.release		= target_core_hba_release,
 };
 
-static struct config_item_type target_core_hba_cit = {
+static const struct config_item_type target_core_hba_cit = {
 	.ct_item_ops		= &target_core_hba_item_ops,
 	.ct_group_ops		= &target_core_hba_group_ops,
 	.ct_attrs		= target_core_hba_attrs,
@@ -3188,7 +3188,7 @@ static void target_core_call_delhbafromtarget(
 	.drop_item	= target_core_call_delhbafromtarget,
 };
 
-static struct config_item_type target_core_cit = {
+static const struct config_item_type target_core_cit = {
 	.ct_item_ops	= NULL,
 	.ct_group_ops	= &target_core_group_ops,
 	.ct_attrs	= NULL,
diff --git a/drivers/target/target_core_stat.c b/drivers/target/target_core_stat.c
index 8038255..f0db91e 100644
--- a/drivers/target/target_core_stat.c
+++ b/drivers/target/target_core_stat.c
@@ -96,7 +96,7 @@ static ssize_t target_stat_ports_show(struct config_item *item, char *page)
 	NULL,
 };
 
-static struct config_item_type target_stat_scsi_dev_cit = {
+static const struct config_item_type target_stat_scsi_dev_cit = {
 	.ct_attrs		= target_stat_scsi_dev_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -193,7 +193,7 @@ static ssize_t target_stat_tgt_aborts_no_task_show(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type target_stat_scsi_tgt_dev_cit = {
+static const struct config_item_type target_stat_scsi_tgt_dev_cit = {
 	.ct_attrs		= target_stat_scsi_tgt_dev_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -414,7 +414,7 @@ static ssize_t target_stat_lu_creation_time_show(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type target_stat_scsi_lu_cit = {
+static const struct config_item_type target_stat_scsi_lu_cit = {
 	.ct_attrs		= target_stat_scsi_lu_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -540,7 +540,7 @@ static ssize_t target_stat_port_busy_count_show(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type target_stat_scsi_port_cit = {
+static const struct config_item_type target_stat_scsi_port_cit = {
 	.ct_attrs		= target_stat_scsi_port_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -724,7 +724,7 @@ static ssize_t target_stat_tgt_port_hs_in_cmds_show(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type target_stat_scsi_tgt_port_cit = {
+static const struct config_item_type target_stat_scsi_tgt_port_cit = {
 	.ct_attrs		= target_stat_scsi_tgt_port_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -844,7 +844,7 @@ static ssize_t target_stat_transport_proto_id_show(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type target_stat_scsi_transport_cit = {
+static const struct config_item_type target_stat_scsi_transport_cit = {
 	.ct_attrs		= target_stat_scsi_transport_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -1206,7 +1206,7 @@ static ssize_t target_stat_auth_row_status_show(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type target_stat_scsi_auth_intr_cit = {
+static const struct config_item_type target_stat_scsi_auth_intr_cit = {
 	.ct_attrs		= target_stat_scsi_auth_intr_attrs,
 	.ct_owner		= THIS_MODULE,
 };
@@ -1378,7 +1378,7 @@ static ssize_t target_stat_iport_port_ident_show(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type target_stat_scsi_att_intr_port_cit = {
+static const struct config_item_type target_stat_scsi_att_intr_port_cit = {
 	.ct_attrs		= target_stat_scsi_ath_intr_port_attrs,
 	.ct_owner		= THIS_MODULE,
 };
diff --git a/include/target/iscsi/iscsi_target_stat.h b/include/target/iscsi/iscsi_target_stat.h
index c27dd47..36e9c9a 100644
--- a/include/target/iscsi/iscsi_target_stat.h
+++ b/include/target/iscsi/iscsi_target_stat.h
@@ -8,16 +8,16 @@
 /*
  * For struct iscsi_tiqn->tiqn_wwn default groups
  */
-extern struct config_item_type iscsi_stat_instance_cit;
-extern struct config_item_type iscsi_stat_sess_err_cit;
-extern struct config_item_type iscsi_stat_tgt_attr_cit;
-extern struct config_item_type iscsi_stat_login_cit;
-extern struct config_item_type iscsi_stat_logout_cit;
+extern const struct config_item_type iscsi_stat_instance_cit;
+extern const struct config_item_type iscsi_stat_sess_err_cit;
+extern const struct config_item_type iscsi_stat_tgt_attr_cit;
+extern const struct config_item_type iscsi_stat_login_cit;
+extern const struct config_item_type iscsi_stat_logout_cit;
 
 /*
  * For struct iscsi_session->se_sess default groups
  */
-extern struct config_item_type iscsi_stat_sess_cit;
+extern const struct config_item_type iscsi_stat_sess_cit;
 
 /* iSCSI session error types */
 #define ISCSI_SESS_ERR_UNKNOWN		0
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
