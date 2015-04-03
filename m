From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] l2tp: unregister l2tp_net_ops on failure path
Date: Fri,  3 Apr 2015 13:46:09 -0700
Message-ID: <1428093969-4224-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34400 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752889AbbDCUqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 16:46:19 -0400
Received: by pdbni2 with SMTP id ni2so132021745pdb.1
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 13:46:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/l2tp/l2tp_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 895348e..a29a504 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1871,6 +1871,7 @@ static int __init l2tp_init(void)
 	l2tp_wq = alloc_workqueue("l2tp", WQ_UNBOUND, 0);
 	if (!l2tp_wq) {
 		pr_err("alloc_workqueue failed\n");
+		unregister_pernet_device(&l2tp_net_ops);
 		rc = -ENOMEM;
 		goto out;
 	}
-- 
1.8.3.1
