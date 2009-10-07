From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 1/3] Fix redeclaration of symbol len
Date: Wed,  7 Oct 2009 23:34:40 +0200
Message-ID: <1254951282-5056-2-git-send-email-hagen@jauu.net>
References: <1254951282-5056-1-git-send-email-hagen@jauu.net>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:35218 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754101AbZJGVoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 17:44:34 -0400
In-Reply-To: <1254951282-5056-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function argument len was redeclarated within the
function. This patch fix the redeclaration of symbol 'len'.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/econet/af_econet.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 6529be3..5e9426a 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -457,15 +457,15 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 	iov[0].iov_len = size;
 	for (i = 0; i < msg->msg_iovlen; i++) {
 		void __user *base = msg->msg_iov[i].iov_base;
-		size_t len = msg->msg_iov[i].iov_len;
+		size_t iov_len = msg->msg_iov[i].iov_len;
 		/* Check it now since we switch to KERNEL_DS later. */
-		if (!access_ok(VERIFY_READ, base, len)) {
+		if (!access_ok(VERIFY_READ, base, iov_len)) {
 			mutex_unlock(&econet_mutex);
 			return -EFAULT;
 		}
 		iov[i+1].iov_base = base;
-		iov[i+1].iov_len = len;
-		size += len;
+		iov[i+1].iov_len = iov_len;
+		size += iov_len;
 	}
 
 	/* Get a skbuff (no data, just holds our cb information) */
-- 
1.6.3.GIT

