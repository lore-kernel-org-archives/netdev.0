From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] pktgen: Fix unsigned function that is returning negative vals
Date: Thu, 19 Jan 2012 20:40:06 -0500
Message-ID: <1327023606-24851-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35291 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620Ab2ATBkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 20:40:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every call to num_args() immediately checks the return value for
less than zero, as it will return -EFAULT for a failed get_user()
call.  So it makes no sense for the function to be declared as an
unsigned long.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 65f80c7..4d8ce93 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -767,8 +767,8 @@ done:
 	return i;
 }
 
-static unsigned long num_arg(const char __user * user_buffer,
-			     unsigned long maxlen, unsigned long *num)
+static long num_arg(const char __user *user_buffer, unsigned long maxlen,
+				unsigned long *num)
 {
 	int i;
 	*num = 0;
-- 
1.7.7.2
