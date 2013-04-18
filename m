From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] pkt_sched: fix error return code in fw_change_attrs()
Date: Thu, 18 Apr 2013 10:49:10 +0800
Message-ID: <CAPgLHd-cDj8j3tKofRMwJ8GE39LkO8ZvtTJ34aSFDSHO+7GjnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: jhs@mojatatu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:57291 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965101Ab3DRCtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 22:49:11 -0400
Received: by mail-wi0-f179.google.com with SMTP id l13so1740055wie.6
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 19:49:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return -EINVAL when tb[TCA_FW_MASK] is set and head->mask != 0xFFFFFFFF
instead of 0 (ifdef CONFIG_NET_CLS_IND and tb[TCA_FW_INDEV]), as done elsewhere
in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/sched/cls_fw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 1135d82..9b97172 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -204,7 +204,6 @@ fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	if (err < 0)
 		return err;
 
-	err = -EINVAL;
 	if (tb[TCA_FW_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_FW_CLASSID]);
 		tcf_bind_filter(tp, &f->res, base);
@@ -218,6 +217,7 @@ fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	}
 #endif /* CONFIG_NET_CLS_IND */
 
+	err = -EINVAL;
 	if (tb[TCA_FW_MASK]) {
 		mask = nla_get_u32(tb[TCA_FW_MASK]);
 		if (mask != head->mask)
