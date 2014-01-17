From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net_sched: fix error return code in fw_change_attrs()
Date: Fri, 17 Jan 2014 09:53:20 +0800
Message-ID: <CAPgLHd_cjvdEcYZZNGg1rwKRBQcUS74vGvsdmTNkSWpPqR+fMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: jhs@mojatatu.com, davem@davemloft.net, xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:40907 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbaAQBxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:53:22 -0500
Received: by mail-bk0-f53.google.com with SMTP id na10so1444033bkb.26
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 17:53:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The error code was not set if change indev fail, so the error
condition wasn't reflected in the return value. Fix to return a
negative error code from this error handling case instead of 0.

Fixes: 2519a602c273 ('net_sched: optimize tcf_match_indev()')
Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/sched/cls_fw.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index ed00e8c..a366537 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -209,8 +209,10 @@ fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	if (tb[TCA_FW_INDEV]) {
 		int ret;
 		ret = tcf_change_indev(net, tb[TCA_FW_INDEV]);
-		if (ret < 0)
+		if (ret < 0) {
+			err = ret;
 			goto errout;
+		}
 		f->ifindex = ret;
 	}
 #endif /* CONFIG_NET_CLS_IND */
