From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: fix a compile warning in act_ife
Date: Fri, 13 Oct 2017 12:58:13 -0700
Message-ID: <20171013195813.25321-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Roman Mashak <mrv@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:56123 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdJMT6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 15:58:25 -0400
Received: by mail-pf0-f195.google.com with SMTP id 17so11170731pfn.12
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 12:58:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apparently ife_meta_id2name() is only called when
CONFIG_MODULES is defined.

This fixes:

net/sched/act_ife.c:251:20: warning: ‘ife_meta_id2name’ defined but not used [-Wunused-function]
 static const char *ife_meta_id2name(u32 metaid)
                    ^~~~~~~~~~~~~~~~

Fixes: d3f24ba895f0 ("net sched actions: fix module auto-loading")
Cc: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_ife.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 252ee7d8c731..3007cb1310ea 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -248,6 +248,7 @@ static int ife_validate_metatype(struct tcf_meta_ops *ops, void *val, int len)
 	return ret;
 }
 
+#ifdef CONFIG_MODULES
 static const char *ife_meta_id2name(u32 metaid)
 {
 	switch (metaid) {
@@ -261,6 +262,7 @@ static const char *ife_meta_id2name(u32 metaid)
 		return "unknown";
 	}
 }
+#endif
 
 /* called when adding new meta information
  * under ife->tcf_lock for existing action
-- 
2.13.0
