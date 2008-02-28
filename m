From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 14/15] [WANROUTER]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 18:58:35 +0800
Message-ID: <47C693DB.7040002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65040 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756670AbYB1LBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 06:01:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/wanrouter/wanproc.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/wanrouter/wanproc.c b/net/wanrouter/wanproc.c
index f2e54c3..5bebe40 100644
--- a/net/wanrouter/wanproc.c
+++ b/net/wanrouter/wanproc.c
@@ -292,14 +292,12 @@ int __init wanrouter_proc_init(void)
 	if (!proc_router)
 		goto fail;
 
-	p = create_proc_entry("config", S_IRUGO, proc_router);
+	p = proc_create("config", S_IRUGO, proc_router, &config_fops);
 	if (!p)
 		goto fail_config;
-	p->proc_fops = &config_fops;
-	p = create_proc_entry("status", S_IRUGO, proc_router);
+	p = proc_create("status", S_IRUGO, proc_router, &status_fops);
 	if (!p)
 		goto fail_stat;
-	p->proc_fops = &status_fops;
 	return 0;
 fail_stat:
 	remove_proc_entry("config", proc_router);
@@ -329,10 +327,10 @@ int wanrouter_proc_add(struct wan_device* wandev)
 	if (wandev->magic != ROUTER_MAGIC)
 		return -EINVAL;
 
-	wandev->dent = create_proc_entry(wandev->name, S_IRUGO, proc_router);
+	wandev->dent = proc_create(wandev->name, S_IRUGO,
+				   proc_router, &wandev_fops);
 	if (!wandev->dent)
 		return -ENOMEM;
-	wandev->dent->proc_fops	= &wandev_fops;
 	wandev->dent->data	= wandev;
 	return 0;
 }
-- 
WCN


