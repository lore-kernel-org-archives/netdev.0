From: Dave Jones <davej@redhat.com>
Subject: Remove printk from rds_sendmsg
Date: Mon, 19 Mar 2012 19:01:07 -0400
Message-ID: <20120319230107.GA23987@redhat.com>
References: <20120319224008.GA23036@redhat.com>
 <20120319.184335.1229962428916453634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58926 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756578Ab2CSXBN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 19:01:13 -0400
Content-Disposition: inline
In-Reply-To: <20120319.184335.1229962428916453634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

no socket layer outputs a message for this error and neither should rds.

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux/net/rds/send.c	2011-11-07 12:00:32.000000000 -0500
+++ linux/net/rds/send.c	2012-03-19 18:59:55.905890597 -0400
@@ -935,7 +935,6 @@ int rds_sendmsg(struct kiocb *iocb, stru
 	/* Mirror Linux UDP mirror of BSD error message compatibility */
 	/* XXX: Perhaps MSG_MORE someday */
 	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_CMSG_COMPAT)) {
-		printk(KERN_INFO "msg_flags 0x%08X\n", msg->msg_flags);
 		ret = -EOPNOTSUPP;
 		goto out;
 	}
