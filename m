From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/34] net: sched: ematch: obtain net pointer from blocks
Date: Thu, 12 Oct 2017 19:17:54 +0200
Message-ID: <20171012171823.1431-6-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35312 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752311AbdJLRSa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:30 -0400
Received: by mail-wm0-f65.google.com with SMTP id b189so4344628wmd.2
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:29 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
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
