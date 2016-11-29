From: Yi Zhao <yi.zhao@windriver.com>
Subject: [PATCH] xfrm_user: fix return value from xfrm_user_rcv_msg
Date: Tue, 29 Nov 2016 18:09:01 +0800
Message-ID: <1480414141-17801-1-git-send-email-yi.zhao@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fan.du@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:58084 "EHLO mail5.wrs.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933530AbcK2KJW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 05:09:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't support to run 32bit 'ip' to set xfrm objdect on 64bit host.
But the return value is unknown for user program:

ip xfrm policy list
RTNETLINK answers: Unknown error 524

Replace ENOTSUPP with EOPNOTSUPP:

ip xfrm policy list
RTNETLINK answers: Operation not supported

Signed-off-by: Yi Zhao <yi.zhao@windriver.com>
---
 net/xfrm/xfrm_user.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 0889209..671a1d0 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2450,7 +2450,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 #ifdef CONFIG_COMPAT
 	if (in_compat_syscall())
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 #endif
 
 	type = nlh->nlmsg_type;
-- 
2.7.4
