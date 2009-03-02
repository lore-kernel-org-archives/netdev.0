From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 3/5] sctp: fix the length check in sctp_getsockopt_maxburst()
Date: Mon,  2 Mar 2009 14:46:12 -0500
Message-ID: <1236023174-18314-4-git-send-email-vladislav.yasevich@hp.com>
References: <>
 <1236023174-18314-1-git-send-email-vladislav.yasevich@hp.com>
 <1236023174-18314-2-git-send-email-vladislav.yasevich@hp.com>
 <1236023174-18314-3-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:34376 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259AbZCBTqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 14:46:23 -0500
In-Reply-To: <1236023174-18314-3-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

The code in sctp_getsockopt_maxburst() doesn't allow len to be larger
then struct sctp_assoc_value, which is a common case where app writers
just pass down the sizeof(buf) or something similar.

This patch fix the problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 4bc558c..bbd3cd2 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5286,7 +5286,8 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
 		printk(KERN_WARNING
 		   "SCTP: Use struct sctp_assoc_value instead\n");
 		params.assoc_id = 0;
-	} else if (len == sizeof (struct sctp_assoc_value)) {
+	} else if (len >= sizeof(struct sctp_assoc_value)) {
+		len = sizeof(struct sctp_assoc_value);
 		if (copy_from_user(&params, optval, len))
 			return -EFAULT;
 	} else
-- 
1.5.4.3

