From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 13/15] [8021Q]: Use proc_create() to setup ->proc_fops first
Date: Thu, 28 Feb 2008 18:58:24 +0800
Message-ID: <47C693D0.3090007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56647 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756658AbYB1LAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 06:00:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/8021q/vlanproc.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index a0ec479..146cfb0 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -161,11 +161,10 @@ int __init vlan_proc_init(void)
 	if (!proc_vlan_dir)
 		goto err;
 
-	proc_vlan_conf = create_proc_entry(name_conf, S_IFREG|S_IRUSR|S_IWUSR,
-					   proc_vlan_dir);
+	proc_vlan_conf = proc_create(name_conf, S_IFREG|S_IRUSR|S_IWUSR,
+				     proc_vlan_dir, &vlan_fops);
 	if (!proc_vlan_conf)
 		goto err;
-	proc_vlan_conf->proc_fops = &vlan_fops;
 	return 0;
 
 err:
@@ -182,13 +181,11 @@ int vlan_proc_add_dev(struct net_device *vlandev)
 {
 	struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
 
-	dev_info->dent = create_proc_entry(vlandev->name,
-					   S_IFREG|S_IRUSR|S_IWUSR,
-					   proc_vlan_dir);
+	dev_info->dent = proc_create(vlandev->name, S_IFREG|S_IRUSR|S_IWUSR,
+				     proc_vlan_dir, &vlandev_fops);
 	if (!dev_info->dent)
 		return -ENOBUFS;
 
-	dev_info->dent->proc_fops = &vlandev_fops;
 	dev_info->dent->data = vlandev;
 	return 0;
 }
-- 
WCN


