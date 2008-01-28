From: maximilian attems <max@stro.at>
Subject: [PATCH] [AX25]: Kill ax25_bind() user triggable printk.
Date: Mon, 28 Jan 2008 18:31:09 +0100
Message-ID: <1201541470-25312-1-git-send-email-max@stro.at>
Cc: netdev@vger.kernel.org, maximilian attems <max@stro.at>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:53634 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760183AbYA1Rbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 12:31:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

on the last run overlooked that sfuzz triggable message.
move the message to the corresponding comment.

Signed-off-by: maximilian attems <max@stro.at>
---
 net/ax25/af_ax25.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index b4725ff..a2cc7c1 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1038,16 +1038,13 @@ static int ax25_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	int err = 0;
 
 	if (addr_len != sizeof(struct sockaddr_ax25) &&
-	    addr_len != sizeof(struct full_sockaddr_ax25)) {
-		/* support for old structure may go away some time */
+	    addr_len != sizeof(struct full_sockaddr_ax25))
+		/* support for old structure may go away some time
+		 * ax25_bind(): uses old (6 digipeater) socket structure.
+		 */
 		if ((addr_len < sizeof(struct sockaddr_ax25) + sizeof(ax25_address) * 6) ||
-		    (addr_len > sizeof(struct full_sockaddr_ax25))) {
+		    (addr_len > sizeof(struct full_sockaddr_ax25)))
 			return -EINVAL;
-	}
-
-		printk(KERN_WARNING "ax25_bind(): %s uses old (6 digipeater) socket structure.\n",
-			current->comm);
-	}
 
 	if (addr->fsa_ax25.sax25_family != AF_AX25)
 		return -EINVAL;
-- 
1.5.4.rc4

