From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] tc: cls_bpf: rename bpf_len to bpf_num_ops
Date: Wed, 14 Jan 2015 10:54:57 +0100
Message-ID: <1421229297-14473-2-git-send-email-jiri@resnulli.us>
References: <1421229297-14473-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, dborkman@redhat.com,
	ast@plumgrid.com, hannes@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:49497 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbbANJzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 04:55:03 -0500
Received: by mail-we0-f179.google.com with SMTP id q59so7717281wes.10
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 01:55:01 -0800 (PST)
In-Reply-To: <1421229297-14473-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was suggested by DaveM to change the name as "len" might indicate
unit bytes.

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_bpf.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 84c8219..1029923 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -37,7 +37,7 @@ struct cls_bpf_prog {
 	struct tcf_result res;
 	struct list_head link;
 	u32 handle;
-	u16 bpf_len;
+	u16 bpf_num_ops;
 	struct tcf_proto *tp;
 	struct rcu_head rcu;
 };
@@ -160,7 +160,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	struct tcf_exts exts;
 	struct sock_fprog_kern tmp;
 	struct bpf_prog *fp;
-	u16 bpf_size, bpf_len;
+	u16 bpf_size, bpf_num_ops;
 	u32 classid;
 	int ret;
 
@@ -173,13 +173,13 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 		return ret;
 
 	classid = nla_get_u32(tb[TCA_BPF_CLASSID]);
-	bpf_len = nla_get_u16(tb[TCA_BPF_OPS_LEN]);
-	if (bpf_len > BPF_MAXINSNS || bpf_len == 0) {
+	bpf_num_ops = nla_get_u16(tb[TCA_BPF_OPS_LEN]);
+	if (bpf_num_ops > BPF_MAXINSNS || bpf_num_ops == 0) {
 		ret = -EINVAL;
 		goto errout;
 	}
 
-	bpf_size = bpf_len * sizeof(*bpf_ops);
+	bpf_size = bpf_num_ops * sizeof(*bpf_ops);
 	bpf_ops = kzalloc(bpf_size, GFP_KERNEL);
 	if (bpf_ops == NULL) {
 		ret = -ENOMEM;
@@ -188,14 +188,14 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 
 	memcpy(bpf_ops, nla_data(tb[TCA_BPF_OPS]), bpf_size);
 
-	tmp.len = bpf_len;
+	tmp.len = bpf_num_ops;
 	tmp.filter = bpf_ops;
 
 	ret = bpf_prog_create(&fp, &tmp);
 	if (ret)
 		goto errout_free;
 
-	prog->bpf_len = bpf_len;
+	prog->bpf_num_ops = bpf_num_ops;
 	prog->bpf_ops = bpf_ops;
 	prog->filter = fp;
 	prog->res.classid = classid;
@@ -303,10 +303,10 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	if (nla_put_u32(skb, TCA_BPF_CLASSID, prog->res.classid))
 		goto nla_put_failure;
-	if (nla_put_u16(skb, TCA_BPF_OPS_LEN, prog->bpf_len))
+	if (nla_put_u16(skb, TCA_BPF_OPS_LEN, prog->bpf_num_ops))
 		goto nla_put_failure;
 
-	nla = nla_reserve(skb, TCA_BPF_OPS, prog->bpf_len *
+	nla = nla_reserve(skb, TCA_BPF_OPS, prog->bpf_num_ops *
 			  sizeof(struct sock_filter));
 	if (nla == NULL)
 		goto nla_put_failure;
-- 
1.9.3
