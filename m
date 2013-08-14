From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] rtnetlink: remove an unneeded test
Date: Wed, 14 Aug 2013 12:35:42 +0300
Message-ID: <20130814093542.GC521@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51617 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab3HNJgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 05:36:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We know that "dev" is a valid pointer at this point, so we can remove
the test and clean up a little.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 618dbe4..e7e058e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1867,10 +1867,10 @@ replay:
 		else
 			err = register_netdevice(dev);
 
-		if (err < 0 && !IS_ERR(dev))
+		if (err < 0) {
 			free_netdev(dev);
-		if (err < 0)
 			goto out;
+		}
 
 		err = rtnl_configure_link(dev, ifm);
 		if (err < 0)
