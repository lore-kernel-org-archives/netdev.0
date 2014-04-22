From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH] netprio_cgroup: explicitly init the early_init field
Date: Tue, 22 Apr 2014 13:32:02 +0800
Message-ID: <1398144722-9864-1-git-send-email-nasa4836@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, lizefan@huawei.com, tj@kernel.org,
	nhorman@tuxdriver.com, daniel.wagner@bmw-carit.de,
	nasa4836@gmail.com, gaofeng@cn.fujitsu.com,
	stephen@networkplumber.org, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:49958 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbaDVFcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 01:32:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For a cgroup subsystem who should init early, then it should carefully
take care of the implementation of css_alloc, because it will be called
before mm_init() setup the world.

Luckily we don't, and we better explicitly assign the early_init field
to 0, for document reason.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 net/core/netprio_cgroup.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 13ddd68..fc21035 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -250,6 +250,7 @@ struct cgroup_subsys net_prio_cgrp_subsys = {
 	.css_free	= cgrp_css_free,
 	.attach		= net_prio_attach,
 	.base_cftypes	= ss_files,
+	.early_init	= 0,
 };
 
 static int netprio_device_event(struct notifier_block *unused,
-- 
2.0.0-rc0
