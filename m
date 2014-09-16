From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 4/4] net: sched: cls_fw: add missing
 tcf_exts_init call in fw_change()
Date: Mon, 15 Sep 2014 23:31:42 -0700
Message-ID: <20140916063141.2905.59421.stgit@nitbit.x32>
References: <20140916063024.2905.55403.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:50180 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbaIPGb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 02:31:58 -0400
Received: by mail-ob0-f172.google.com with SMTP id va2so1809190obc.17
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 23:31:57 -0700 (PDT)
In-Reply-To: <20140916063024.2905.55403.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When allocating a new structure we also need to call tcf_exts_init
to initialize exts.

A follow up patch might be in order to remove some of this code
and do tcf_exts_assign(). With this we could remove the
tcf_exts_init/tcf_exts_change pattern for some of the classifiers.
As part of the future tcf_actions RCU series this will need to be
done. For now fix the call here.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_fw.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 006b45a..2650285 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -264,6 +264,8 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 #endif /* CONFIG_NET_CLS_IND */
 		fnew->tp = f->tp;
 
+		tcf_exts_init(&fnew->exts, TCA_FW_ACT, TCA_FW_POLICE);
+
 		err = fw_change_attrs(net, tp, fnew, tb, tca, base, ovr);
 		if (err < 0) {
 			kfree(fnew);
