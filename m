From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] fou: avoid missing unlock in failure path
Date: Tue, 14 Apr 2015 09:32:30 -0700
Message-ID: <1429029150-31710-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Tom Herbert <tom@herbertland.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34804 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852AbbDNQco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 12:32:44 -0400
Received: by pacyx8 with SMTP id yx8so17307966pac.1
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 09:32:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/fou.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 2637102..1df3399 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -711,11 +711,10 @@ static int fou_nl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 				    cb->nlh->nlmsg_seq, NLM_F_MULTI,
 				    skb, FOU_CMD_GET);
 		if (ret)
-			goto done;
+			break;
 	}
 	mutex_unlock(&fn->fou_lock);
 
-done:
 	cb->args[0] = idx;
 	return skb->len;
 }
-- 
1.8.3.1
