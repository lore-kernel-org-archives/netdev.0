From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2 05/15] ocfs2/cluster: make
	config_item_type const
Date: Mon, 16 Oct 2017 17:18:44 +0200
Message-ID: <1508167134-6243-6-git-send-email-bhumirks@gmail.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
	alexander.shishkin@linux.intel.com, jic23@kernel.org, knaack.h@gmx.de,
	lars@metafoo.de, pmeerw@pmeerw.net, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, hch@lst.de,
	sagi@grimberg.me, kishon@ti.com, bhelgaas@google.com,
	nab@linux-iscsi.org, balbi@kernel.org, gregkh@linuxfoundation.org,
	laurent.pinchart@ideasonboard.com, jlbec@evilplan.org,
	ccaulfie@redhat.com, teigland@redhat.com, mfasheh@versity.com,
	linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, linux-usb@vger.kernel.org,
	cluster-devel@redhat.com, ocfs2-devel@oss.oracle.com,
	linux-fsdevel@vger.kernel.org
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Make these structures const as they are either passed to the functions
having the argument as const or stored as a reference in the "ci_type"
const field of a config_item structure.

Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
* Changes in v2- Combine all the followup patches and the constification
patches into a series.

 fs/ocfs2/cluster/heartbeat.c   | 4 ++--
 fs/ocfs2/cluster/nodemanager.c | 8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/ocfs2/cluster/heartbeat.c b/fs/ocfs2/cluster/heartbeat.c
index d020604..ea8c551 100644
--- a/fs/ocfs2/cluster/heartbeat.c
+++ b/fs/ocfs2/cluster/heartbeat.c
@@ -2025,7 +2025,7 @@ static ssize_t o2hb_region_pid_show(struct config_item *item, char *page)
 	.release		= o2hb_region_release,
 };
 
-static struct config_item_type o2hb_region_type = {
+static const struct config_item_type o2hb_region_type = {
 	.ct_item_ops	= &o2hb_region_item_ops,
 	.ct_attrs	= o2hb_region_attrs,
 	.ct_owner	= THIS_MODULE,
@@ -2310,7 +2310,7 @@ static ssize_t o2hb_heartbeat_group_mode_store(struct config_item *item,
 	.drop_item	= o2hb_heartbeat_group_drop_item,
 };
 
-static struct config_item_type o2hb_heartbeat_group_type = {
+static const struct config_item_type o2hb_heartbeat_group_type = {
 	.ct_group_ops	= &o2hb_heartbeat_group_group_ops,
 	.ct_attrs	= o2hb_heartbeat_group_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/fs/ocfs2/cluster/nodemanager.c b/fs/ocfs2/cluster/nodemanager.c
index b17d180..a51200e 100644
--- a/fs/ocfs2/cluster/nodemanager.c
+++ b/fs/ocfs2/cluster/nodemanager.c
@@ -378,7 +378,7 @@ static ssize_t o2nm_node_local_store(struct config_item *item, const char *page,
 	.release		= o2nm_node_release,
 };
 
-static struct config_item_type o2nm_node_type = {
+static const struct config_item_type o2nm_node_type = {
 	.ct_item_ops	= &o2nm_node_item_ops,
 	.ct_attrs	= o2nm_node_attrs,
 	.ct_owner	= THIS_MODULE,
@@ -619,7 +619,7 @@ static void o2nm_node_group_drop_item(struct config_group *group,
 	.drop_item	= o2nm_node_group_drop_item,
 };
 
-static struct config_item_type o2nm_node_group_type = {
+static const struct config_item_type o2nm_node_group_type = {
 	.ct_group_ops	= &o2nm_node_group_group_ops,
 	.ct_owner	= THIS_MODULE,
 };
@@ -637,7 +637,7 @@ static void o2nm_cluster_release(struct config_item *item)
 	.release	= o2nm_cluster_release,
 };
 
-static struct config_item_type o2nm_cluster_type = {
+static const struct config_item_type o2nm_cluster_type = {
 	.ct_item_ops	= &o2nm_cluster_item_ops,
 	.ct_attrs	= o2nm_cluster_attrs,
 	.ct_owner	= THIS_MODULE,
@@ -722,7 +722,7 @@ static void o2nm_cluster_group_drop_item(struct config_group *group, struct conf
 	.drop_item	= o2nm_cluster_group_drop_item,
 };
 
-static struct config_item_type o2nm_cluster_group_type = {
+static const struct config_item_type o2nm_cluster_group_type = {
 	.ct_group_ops	= &o2nm_cluster_group_group_ops,
 	.ct_owner	= THIS_MODULE,
 };
-- 
1.9.1
