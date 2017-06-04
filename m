From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] net: sched: fix mips build failure
Date: Sun,  4 Jun 2017 22:44:13 +0100
Message-ID: <1496612653-12419-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-mips@linux-mips.org,
        Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35504 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751077AbdFDVoW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 17:44:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The build of mips ar7_defconfig was failing with the error:
../net/sched/act_api.c: In function 'tcf_action_goto_chain_init':
../net/sched/act_api.c:37:18: error:
	implicit declaration of function 'tcf_chain_get'
	[-Werror=implicit-function-declaration]

../net/sched/act_api.c: In function 'tcf_action_goto_chain_fini':
../net/sched/act_api.c:45:2: error:
	implicit declaration of function 'tcf_chain_put'
	[-Werror=implicit-function-declaration]

Add two inline helpers for the case where CONFIG_NET_CLS is not enabled.

Signed-off-by: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
---

The build log of the latest linux-next is at:
https://travis-ci.org/sudipm-mukherjee/parport/jobs/238623031/

 include/net/pkt_cls.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 537d0a0..c34ade5 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -29,6 +29,17 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 #else
 static inline
+struct tcf_chain *tcf_chain_get(struct tcf_block *block,
+				u32 chain_index, bool create)
+{
+	return NULL;
+}
+
+static inline void tcf_chain_put(struct tcf_chain *chain)
+{
+}
+
+static inline
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain)
 {
-- 
2.7.4
