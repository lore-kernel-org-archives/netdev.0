From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/9] net: sched: ematch: obtain net pointer from blocks
Date: Fri, 13 Oct 2017 14:01:01 +0200
Message-ID: <20171013120105.23358-6-jiri@resnulli.us>
References: <20171013120105.23358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37659 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757973AbdJMMBN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 08:01:13 -0400
Received: by mail-wm0-f65.google.com with SMTP id r68so5588230wmr.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 05:01:12 -0700 (PDT)
In-Reply-To: <20171013120105.23358-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Instead of using tp->q, use block to get the net pointer.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/ematch.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 03b677b..1331a4c 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -178,7 +178,7 @@ static int tcf_em_validate(struct tcf_proto *tp,
 	struct tcf_ematch_hdr *em_hdr = nla_data(nla);
 	int data_len = nla_len(nla) - sizeof(*em_hdr);
 	void *data = (void *) em_hdr + sizeof(*em_hdr);
-	struct net *net = dev_net(qdisc_dev(tp->q));
+	struct net *net = tp->chain->block->net;
 
 	if (!TCF_EM_REL_VALID(em_hdr->flags))
 		goto errout;
-- 
2.9.5
