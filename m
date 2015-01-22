From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] net: act_bpf: fix size mismatch on filter preparation
Date: Thu, 22 Jan 2015 10:58:19 +0100
Message-ID: <1421920699-26556-3-git-send-email-dborkman@redhat.com>
References: <1421920699-26556-1-git-send-email-dborkman@redhat.com>
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244AbbAVJ60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 04:58:26 -0500
In-Reply-To: <1421920699-26556-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly as in cls_bpf, also this code needs to reject mismatches.

Reference: http://article.gmane.org/gmane.linux.network/347406
Fixes: d23b8ad8ab23 ("tc: add BPF based action")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/act_bpf.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 1bd257e..82c5d7f 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -122,6 +122,9 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 		return -EINVAL;
 
 	bpf_size = bpf_num_ops * sizeof(*bpf_ops);
+	if (bpf_size != nla_len(tb[TCA_ACT_BPF_OPS]))
+		return -EINVAL;
+
 	bpf_ops = kzalloc(bpf_size, GFP_KERNEL);
 	if (!bpf_ops)
 		return -ENOMEM;
-- 
1.7.11.7
