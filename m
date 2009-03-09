From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: fix warning about non-const string
Date: Mon, 9 Mar 2009 16:51:55 -0700
Message-ID: <20090309165155.187776c0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38451 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615AbZCIXv6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 19:51:58 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 03E464F420E
	for <netdev@vger.kernel.org>; Mon,  9 Mar 2009 16:52:00 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id S1UpZIE3DWOf for <netdev@vger.kernel.org>;
	Mon,  9 Mar 2009 16:51:59 -0700 (PDT)
Received: from nehalam (pool-71-117-208-104.ptldor.fios.verizon.net [71.117.208.104])
	by mail.vyatta.com (Postfix) with ESMTP id A773C4F4204
	for <netdev@vger.kernel.org>; Mon,  9 Mar 2009 16:51:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since dev_set_name takes a printf style string, new gcc complains
if arg is not const.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/net-sysfs.c	2009-03-09 08:23:45.573308957 -0700
+++ b/net/core/net-sysfs.c	2009-03-09 16:47:46.640356108 -0700
@@ -498,7 +498,7 @@ int netdev_register_kobject(struct net_d
 	dev->groups = groups;
 
 	BUILD_BUG_ON(BUS_ID_SIZE < IFNAMSIZ);
-	dev_set_name(dev, net->name);
+	dev_set_name(dev, "%s", net->name);
 
 #ifdef CONFIG_SYSFS
 	*groups++ = &netstat_group;
