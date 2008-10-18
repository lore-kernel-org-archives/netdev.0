From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netdev: change name dropping error codes
Date: Fri, 17 Oct 2008 21:30:06 -0700
Message-ID: <20081017213006.385c45cd@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37417 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858AbYJREaL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 00:30:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If changename notifier returns an error code, it gets incorrectly
cleared during rollback so the error is never returned to the user.
Found while testing similar code for MTU changes.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/core/dev.c	2008-10-17 18:59:11.000000000 -0700
+++ b/net/core/dev.c	2008-10-17 21:22:30.000000000 -0700
@@ -924,10 +924,10 @@ int dev_change_name(struct net_device *d
 		strlcpy(dev->name, newname, IFNAMSIZ);
 
 rollback:
-	err = device_rename(&dev->dev, dev->name);
-	if (err) {
+	ret = device_rename(&dev->dev, dev->name);
+	if (ret) {
 		memcpy(dev->name, oldname, IFNAMSIZ);
-		return err;
+		return ret;
 	}
 
 	write_lock_bh(&dev_base_lock);
