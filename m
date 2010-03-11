From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 02/13] RDS: sendmsg() should check sndtimeo, not rcvtimeo
Date: Thu, 11 Mar 2010 15:49:56 -0800
Message-ID: <1268351407-7394-3-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:49178 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691Ab0CKXvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:51:03 -0500
Received: from rcsinet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by acsinet12.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNp11h027691
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:51:03 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most likely cut n paste error - sendmsg() was checking sock_rcvtimeo.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/send.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index b2fccfc..ad2e469 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -815,7 +815,7 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	int ret = 0;
 	int queued = 0, allocated_mr = 0;
 	int nonblock = msg->msg_flags & MSG_DONTWAIT;
-	long timeo = sock_rcvtimeo(sk, nonblock);
+	long timeo = sock_sndtimeo(sk, nonblock);
 
 	/* Mirror Linux UDP mirror of BSD error message compatibility */
 	/* XXX: Perhaps MSG_MORE someday */
-- 
1.6.3.3

