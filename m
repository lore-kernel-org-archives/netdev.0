From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH] netclassid_cgroup: explicitly init the early_init field
Date: Tue, 22 Apr 2014 13:31:16 +0800
Message-ID: <1398144676-9739-1-git-send-email-nasa4836@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, lizefan@huawei.com, tj@kernel.org,
	nhorman@tuxdriver.com, aris@redhat.com, dborkman@redhat.com,
	nasa4836@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:37512 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbaDVFbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 01:31:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For a cgroup subsystem who should init early, then it should carefully
take care of the implementation of css_alloc, because it will be called
before mm_init() setup the world.

Luckily we don't, and we better explicitly assign the early_init field
to 0, for document reason.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 net/core/netclassid_cgroup.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
index 22931e1..1b07dca 100644
--- a/net/core/netclassid_cgroup.c
+++ b/net/core/netclassid_cgroup.c
@@ -108,4 +108,5 @@ struct cgroup_subsys net_cls_cgrp_subsys = {
 	.css_free		= cgrp_css_free,
 	.attach			= cgrp_attach,
 	.base_cftypes		= ss_files,
+	.early_init		= 0,
 };
-- 
2.0.0-rc0
