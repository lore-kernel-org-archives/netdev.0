From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] netxen: Use kobj_to_dev()
Date: Wed, 24 Feb 2016 20:09:38 +0530
Message-ID: <20160224143938.GA17198@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce the use of kobj_to_dev() helper function instead of open
coding it with container_of()

The Coccinelle semantic patch used to make this change is as follows:

//<smpl>
@@
expression a;
symbol kobj;
@@
- container_of(a, struct device, kobj)
+ kobj_to_dev(a)
//</smpl>

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 6409a06..fd362b6 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -2891,7 +2891,7 @@ netxen_sysfs_read_crb(struct file *filp, struct kobject *kobj,
 		struct bin_attribute *attr,
 		char *buf, loff_t offset, size_t size)
 {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev = kobj_to_dev(kobj);
 	struct netxen_adapter *adapter = dev_get_drvdata(dev);
 	u32 data;
 	u64 qmdata;
@@ -2919,7 +2919,7 @@ netxen_sysfs_write_crb(struct file *filp, struct kobject *kobj,
 		struct bin_attribute *attr,
 		char *buf, loff_t offset, size_t size)
 {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev = kobj_to_dev(kobj);
 	struct netxen_adapter *adapter = dev_get_drvdata(dev);
 	u32 data;
 	u64 qmdata;
@@ -2960,7 +2960,7 @@ netxen_sysfs_read_mem(struct file *filp, struct kobject *kobj,
 		struct bin_attribute *attr,
 		char *buf, loff_t offset, size_t size)
 {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev = kobj_to_dev(kobj);
 	struct netxen_adapter *adapter = dev_get_drvdata(dev);
 	u64 data;
 	int ret;
@@ -2981,7 +2981,7 @@ static ssize_t netxen_sysfs_write_mem(struct file *filp, struct kobject *kobj,
 		struct bin_attribute *attr, char *buf,
 		loff_t offset, size_t size)
 {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev = kobj_to_dev(kobj);
 	struct netxen_adapter *adapter = dev_get_drvdata(dev);
 	u64 data;
 	int ret;
@@ -3018,7 +3018,7 @@ netxen_sysfs_read_dimm(struct file *filp, struct kobject *kobj,
 		struct bin_attribute *attr,
 		char *buf, loff_t offset, size_t size)
 {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev = kobj_to_dev(kobj);
 	struct netxen_adapter *adapter = dev_get_drvdata(dev);
 	struct net_device *netdev = adapter->netdev;
 	struct netxen_dimm_cfg dimm;
-- 
1.9.1
