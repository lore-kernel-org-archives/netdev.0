From: Dave Jones <davej@redhat.com>
Subject: Improve rds_sendmsg printk
Date: Mon, 19 Mar 2012 18:40:09 -0400
Message-ID: <20120319224008.GA23036@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: venkat.x.venkatsubra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6079 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757610Ab2CSWkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 18:40:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Given this can be called by any user, prevent them from flooding
  the logs by using printk_ratelimited
- Also add a rds: prefix, so it's clear where the message is coming from.

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux/net/rds/send.c	2011-11-07 12:00:32.000000000 -0500
+++ linux/net/rds/send.c	2012-03-19 18:36:21.804991923 -0400
@@ -935,7 +935,7 @@ int rds_sendmsg(struct kiocb *iocb, stru
 	/* Mirror Linux UDP mirror of BSD error message compatibility */
 	/* XXX: Perhaps MSG_MORE someday */
 	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_CMSG_COMPAT)) {
-		printk(KERN_INFO "msg_flags 0x%08X\n", msg->msg_flags);
+		printk_ratelimited(KERN_INFO "rds: msg_flags 0x%08X\n", msg->msg_flags);
 		ret = -EOPNOTSUPP;
 		goto out;
 	}
