From: maximilian attems <max@stro.at>
Subject: [PATCH] AX25: kill user triggable printks
Date: Wed,  9 Jan 2008 11:11:23 +0100
Message-ID: <1199873483-8844-1-git-send-email-max@stro.at>
Cc: netdev@vger.kernel.org, maximilian attems <max@stro.at>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:49866 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbYAIKLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 05:11:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sfuzz can easily trigger any of those.

move the printk message to the corresponding comment:
makes the intention of the code clear and easy
to pick up on an scheduled removal.
as bonus simplify the braces placement.

Signed-off-by: maximilian attems <max@stro.at>
---
 net/ax25/af_ax25.c |   39 ++++++++++++++++++---------------------
 1 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 8378afd..9b04b48 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1109,21 +1109,19 @@ static int __must_check ax25_connect(struct socket *sock,
 	 * some sanity checks. code further down depends on this
 	 */
 
-	if (addr_len == sizeof(struct sockaddr_ax25)) {
-		/* support for this will go away in early 2.5.x */
-		printk(KERN_WARNING "ax25_connect(): %s uses obsolete socket structure\n",
-			current->comm);
-	}
-	else if (addr_len != sizeof(struct full_sockaddr_ax25)) {
-		/* support for old structure may go away some time */
+	if (addr_len == sizeof(struct sockaddr_ax25))
+		/* support for this will go away in early 2.5.x
+		 * ax25_connect(): uses obsolete socket structure
+		 */
+		;
+	else if (addr_len != sizeof(struct full_sockaddr_ax25))
+		/* support for old structure may go away some time
+		 * ax25_connect(): uses old (6 digipeater) socket structure.
+		 */
 		if ((addr_len < sizeof(struct sockaddr_ax25) + sizeof(ax25_address) * 6) ||
-		    (addr_len > sizeof(struct full_sockaddr_ax25))) {
+		    (addr_len > sizeof(struct full_sockaddr_ax25)))
 			return -EINVAL;
-		}
 
-		printk(KERN_WARNING "ax25_connect(): %s uses old (6 digipeater) socket structure.\n",
-			current->comm);
-	}
 
 	if (fsa->fsa_ax25.sax25_family != AF_AX25)
 		return -EINVAL;
@@ -1467,21 +1465,20 @@ static int ax25_sendmsg(struct kiocb *iocb, struct socket *sock,
 			goto out;
 		}
 
-		if (addr_len == sizeof(struct sockaddr_ax25)) {
-			printk(KERN_WARNING "ax25_sendmsg(): %s uses obsolete socket structure\n",
-				current->comm);
-		}
-		else if (addr_len != sizeof(struct full_sockaddr_ax25)) {
-			/* support for old structure may go away some time */
+		if (addr_len == sizeof(struct sockaddr_ax25))
+			/* ax25_sendmsg(): uses obsolete socket structure */
+			;
+		else if (addr_len != sizeof(struct full_sockaddr_ax25))
+			/* support for old structure may go away some time
+			 * ax25_sendmsg(): uses old (6 digipeater)
+			 * socket structure.\n",
+			 */
 			if ((addr_len < sizeof(struct sockaddr_ax25) + sizeof(ax25_address) * 6) ||
 			    (addr_len > sizeof(struct full_sockaddr_ax25))) {
 				err = -EINVAL;
 				goto out;
 			}
 
-			printk(KERN_WARNING "ax25_sendmsg(): %s uses old (6 digipeater) socket structure.\n",
-				current->comm);
-		}
 
 		if (addr_len > sizeof(struct sockaddr_ax25) && usax->sax25_ndigis != 0) {
 			int ct           = 0;
-- 
debian.1.5.3.7.1-dirty

