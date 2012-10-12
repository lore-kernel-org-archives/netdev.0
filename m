From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] RDS: fix an integer overflow check
Date: Fri, 12 Oct 2012 10:31:46 +0300
Message-ID: <20121012073146.GA9543@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:36211 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395Ab2JLHcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 03:32:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"len" is an int.  We verified that len was postive already.  Since
PAGE_SIZE is specified as an unsigned long, the type it promoted to
unsigned and the condition is never true.

I'm not sure this check is actually needed.  It might be that we could
just remove it?

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/rds/info.c b/net/rds/info.c
index 9a6b4f6..4d62618 100644
--- a/net/rds/info.c
+++ b/net/rds/info.c
@@ -176,7 +176,7 @@ int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
 
 	/* check for all kinds of wrapping and the like */
 	start = (unsigned long)optval;
-	if (len < 0 || len + PAGE_SIZE - 1 < len || start + len < start) {
+	if (len < 0 || len > INT_MAX - (PAGE_SIZE - 1) || start + len < start) {
 		ret = -EINVAL;
 		goto out;
 	}
