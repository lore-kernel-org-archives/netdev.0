From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 2/5] net_sched: act_bpf: remove unnecessary copy
Date: Tue, 25 Aug 2015 20:06:32 -0700
Message-ID: <1440558395-7765-3-git-send-email-ast@plumgrid.com>
References: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33656 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbbHZDGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 23:06:44 -0400
Received: by pacti10 with SMTP id ti10so71732854pac.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 20:06:44 -0700 (PDT)
In-Reply-To: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix harmless typo and avoid unnecessary copy of empty 'prog' into
unused 'strcut tcf_bpf_cfg old'.

Fixes: f4eaed28c783 ("act_bpf: fix memory leaks when replacing bpf programs")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/sched/act_bpf.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 1b97dabc621a..458cf647e698 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -327,7 +327,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 	prog = to_bpf(act);
 	spin_lock_bh(&prog->tcf_lock);
 
-	if (ret != ACT_P_CREATED)
+	if (res != ACT_P_CREATED)
 		tcf_bpf_prog_fill_cfg(prog, &old);
 
 	prog->bpf_ops = cfg.bpf_ops;
-- 
1.7.9.5
