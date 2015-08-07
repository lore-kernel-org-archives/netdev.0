From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 26/31] net/sched: use kmemdup rather than duplicating its
 implementation
Date: Fri, 07 Aug 2015 09:59:32 +0200
Message-ID: <1438934377-4922-27-git-send-email-a.hajda@samsung.com>
References: <1438934377-4922-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.w1.samsung.com ([210.118.77.12]:23247 "EHLO
	mailout2.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422659AbbHGIAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 04:00:49 -0400
In-reply-to: <1438934377-4922-1-git-send-email-a.hajda@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch was generated using fixed coccinelle semantic patch
scripts/coccinelle/api/memdup.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2014320

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 net/sched/act_bpf.c | 4 +---
 net/sched/cls_bpf.c | 4 +---
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 1b97dab..5c0fa03 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -190,12 +190,10 @@ static int tcf_bpf_init_from_ops(struct nlattr **tb, struct tcf_bpf_cfg *cfg)
 	if (bpf_size != nla_len(tb[TCA_ACT_BPF_OPS]))
 		return -EINVAL;
 
-	bpf_ops = kzalloc(bpf_size, GFP_KERNEL);
+	bpf_ops = kmemdup(nla_data(tb[TCA_ACT_BPF_OPS]), bpf_size, GFP_KERNEL);
 	if (bpf_ops == NULL)
 		return -ENOMEM;
 
-	memcpy(bpf_ops, nla_data(tb[TCA_ACT_BPF_OPS]), bpf_size);
-
 	fprog_tmp.len = bpf_num_ops;
 	fprog_tmp.filter = bpf_ops;
 
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index e5168f8..423f774 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -212,12 +212,10 @@ static int cls_bpf_prog_from_ops(struct nlattr **tb,
 	if (bpf_size != nla_len(tb[TCA_BPF_OPS]))
 		return -EINVAL;
 
-	bpf_ops = kzalloc(bpf_size, GFP_KERNEL);
+	bpf_ops = kmemdup(nla_data(tb[TCA_BPF_OPS]), bpf_size, GFP_KERNEL);
 	if (bpf_ops == NULL)
 		return -ENOMEM;
 
-	memcpy(bpf_ops, nla_data(tb[TCA_BPF_OPS]), bpf_size);
-
 	fprog_tmp.len = bpf_num_ops;
 	fprog_tmp.filter = bpf_ops;
 
-- 
1.9.1
