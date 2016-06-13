From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net 1/1] net sched actions: bug fix dumping actions directly didnt produce NLMSG_DONE
Date: Mon, 13 Jun 2016 18:08:42 -0400
Message-ID: <1465855722-26727-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33376 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbcFMWIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 18:08:51 -0400
Received: by mail-it0-f67.google.com with SMTP id i6so9007604ith.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 15:08:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

This refers to commands to direct action access as follows:

sudo tc actions add action drop index 12
sudo tc actions add action pipe index 10

And then dumping them like so:
sudo tc actions ls action gact

iproute2 worked because it depended on absence of TCA_ACT_TAB TLV
as end of message.
This fix has been tested with iproute2 and is backward compatible.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 336774a..c7a0b0d 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -1118,7 +1118,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 		nla_nest_end(skb, nest);
 		ret = skb->len;
 	} else
-		nla_nest_cancel(skb, nest);
+		nlmsg_trim(skb, b);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	if (NETLINK_CB(cb->skb).portid && ret)
-- 
1.9.1
