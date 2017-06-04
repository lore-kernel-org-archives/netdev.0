From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: sched: select cls when cls_act is enabled
Date: Sun,  4 Jun 2017 18:49:28 +0200
Message-ID: <20170604164928.15569-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        fengguang.wu@intel.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34026 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdFDQtb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 12:49:31 -0400
Received: by mail-wr0-f193.google.com with SMTP id u101so2999173wrc.1
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2017 09:49:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

It really makes no sense to have cls_act enabled without cls. In that
case, the cls_act code is dead. So select it.

This also fixes an issue recently reported by kbuild robot:
[linux-next:master 1326/4151] net/sched/act_api.c:37:18: error: implicit declaration of function 'tcf_chain_get'

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: db50514f9a9c ("net: sched: add termination action to allow goto chain")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 9fb84f0..e70ed26 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -649,6 +649,7 @@ config NET_EMATCH_IPSET
 
 config NET_CLS_ACT
 	bool "Actions"
+	select NET_CLS
 	---help---
 	  Say Y here if you want to use traffic control actions. Actions
 	  get attached to classifiers and are invoked after a successful
-- 
2.9.3
