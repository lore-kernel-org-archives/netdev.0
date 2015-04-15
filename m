From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2] fou: avoid missing unlock in failure path
Date: Wed, 15 Apr 2015 11:48:49 -0700
Message-ID: <1429123729-8282-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Tom Herbert <tom@herbertland.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36093 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684AbbDOSsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 14:48:55 -0400
Received: by pdea3 with SMTP id a3so61944881pde.3
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 11:48:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 7a6c8c34e5b7 ("fou: implement FOU_CMD_GET")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/fou.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index af150b4..34968cd 100644
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
