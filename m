From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] rtnetlink: remove check for fill_slave_info in rtnl_have_link_slave_info
Date: Thu, 23 Jan 2014 19:19:21 +0100
Message-ID: <1390501161-7890-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@cumulusnetworks.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com,
	vyasevich@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:46380 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138AbaAWST0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 13:19:26 -0500
Received: by mail-wg0-f54.google.com with SMTP id x13so1902237wgg.33
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 10:19:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This check is not needed because the same check is done before
fill_slave_info is used in rtnl_link_slave_info_fill.
Also, by removing this check, kernel will fillup IFLA_INFO_SLAVE_KIND
even for slaves of masters which does not implement fill_slave_info.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/rtnetlink.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index db6a239..393b1bc 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -482,8 +482,7 @@ static bool rtnl_have_link_slave_info(const struct net_device *dev)
 	struct net_device *master_dev;
 
 	master_dev = netdev_master_upper_dev_get((struct net_device *) dev);
-	if (master_dev && master_dev->rtnl_link_ops &&
-	    master_dev->rtnl_link_ops->fill_slave_info)
+	if (master_dev && master_dev->rtnl_link_ops)
 		return true;
 	return false;
 }
-- 
1.8.3.1
