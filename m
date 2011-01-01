From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 16/20] tipc: recode getsockopt error handling for better readability
Date: Fri, 31 Dec 2010 23:59:31 -0500
Message-ID: <1293857975-30267-17-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53338 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040Ab1AAFAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:13 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing code for the copy to user and error handling at the
end of getsockopt isn't easy to follow, due to the excessive use
of if/else.  By simply using return where appropriate, it can be
made smaller and easier to follow at the same time.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |   22 +++++++++-------------
 1 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index f972c0b..1a2eb23 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1755,20 +1755,16 @@ static int getsockopt(struct socket *sock,
 
 	release_sock(sk);
 
-	if (res) {
-		/* "get" failed */
-	}
-	else if (len < sizeof(value)) {
-		res = -EINVAL;
-	}
-	else if (copy_to_user(ov, &value, sizeof(value))) {
-		res = -EFAULT;
-	}
-	else {
-		res = put_user(sizeof(value), ol);
-	}
+	if (res)
+		return res;	/* "get" failed */
 
-	return res;
+	if (len < sizeof(value))
+		return -EINVAL;
+
+	if (copy_to_user(ov, &value, sizeof(value)))
+		return -EFAULT;
+
+	return put_user(sizeof(value), ol);
 }
 
 /**
-- 
1.7.3.3

