From: maximilian attems <max@stro.at>
Subject: [PATCH] AX25: nuke user trigable printks
Date: Mon,  7 Jan 2008 18:55:13 +0100
Message-ID: <1199728513-25258-1-git-send-email-max@stro.at>
Cc: netdev@vger.kernel.org, maximilian attems <max@stro.at>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:43040 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991AbYAGRzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 12:55:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sfuzz trigerrs any of those printk easily.
things that should have gone in early 2.5.x aka years ago
should not be thrown so easily to the user.

Signed-off-by: maximilian attems <max@stro.at>
---
 net/ax25/af_ax25.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 8378afd..62ab6bd 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1111,18 +1111,13 @@ static int __must_check ax25_connect(struct socket *sock,
 
 	if (addr_len == sizeof(struct sockaddr_ax25)) {
 		/* support for this will go away in early 2.5.x */
-		printk(KERN_WARNING "ax25_connect(): %s uses obsolete socket structure\n",
-			current->comm);
+		;
 	}
 	else if (addr_len != sizeof(struct full_sockaddr_ax25)) {
 		/* support for old structure may go away some time */
 		if ((addr_len < sizeof(struct sockaddr_ax25) + sizeof(ax25_address) * 6) ||
-		    (addr_len > sizeof(struct full_sockaddr_ax25))) {
+		    (addr_len > sizeof(struct full_sockaddr_ax25)))
 			return -EINVAL;
-		}
-
-		printk(KERN_WARNING "ax25_connect(): %s uses old (6 digipeater) socket structure.\n",
-			current->comm);
 	}
 
 	if (fsa->fsa_ax25.sax25_family != AF_AX25)
@@ -1468,8 +1463,7 @@ static int ax25_sendmsg(struct kiocb *iocb, struct socket *sock,
 		}
 
 		if (addr_len == sizeof(struct sockaddr_ax25)) {
-			printk(KERN_WARNING "ax25_sendmsg(): %s uses obsolete socket structure\n",
-				current->comm);
+			;
 		}
 		else if (addr_len != sizeof(struct full_sockaddr_ax25)) {
 			/* support for old structure may go away some time */
@@ -1478,9 +1472,6 @@ static int ax25_sendmsg(struct kiocb *iocb, struct socket *sock,
 				err = -EINVAL;
 				goto out;
 			}
-
-			printk(KERN_WARNING "ax25_sendmsg(): %s uses old (6 digipeater) socket structure.\n",
-				current->comm);
 		}
 
 		if (addr_len > sizeof(struct sockaddr_ax25) && usax->sax25_ndigis != 0) {
-- 
debian.1.5.3.7.1-dirty

