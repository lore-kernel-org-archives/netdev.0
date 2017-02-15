From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] sched: have stub for tcf_destroy_chain in case NET_CLS is not configured
Date: Wed, 15 Feb 2017 11:57:50 +0100
Message-ID: <1487156270-31132-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, mlxsw@mellanox.com,
        sd@queasysnail.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35880 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751452AbdBOK5x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 05:57:53 -0500
Received: by mail-wm0-f68.google.com with SMTP id r18so7576640wmd.3
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 02:57:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This fixes broken build for !NET_CLS:

net/built-in.o: In function `fq_codel_destroy':
/home/sab/linux/net-next/net/sched/sch_fq_codel.c:468: undefined reference to `tcf_destroy_chain'

Fixes: cf1facda2f61 ("sched: move tcf_proto_destroy and tcf_destroy_chain helpers into cls_api")
Reported-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 71b266c..be5c12a 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -17,7 +17,13 @@ struct tcf_walker {
 int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
+#ifdef CONFIG_NET_CLS
 void tcf_destroy_chain(struct tcf_proto __rcu **fl);
+#else
+static inline void tcf_destroy_chain(struct tcf_proto __rcu **fl)
+{
+}
+#endif
 
 static inline unsigned long
 __cls_set_class(unsigned long *clp, unsigned long cl)
-- 
2.7.4
