From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipconfig: Only bootp paths should reference ic_dev_xid.
Date: Wed, 09 Jul 2014 22:25:44 -0700 (PDT)
Message-ID: <20140709.222544.1574277089327564341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaGJFZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 01:25:45 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id BF799581CD6
	for <netdev@vger.kernel.org>; Wed,  9 Jul 2014 22:25:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is only tested, and declared, in the bootp code.

So, in ic_dynamic() guard it's setting with IPCONFIG_BOOTP.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ipconfig.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index f02f594..5bbef4f 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1217,10 +1217,10 @@ static int __init ic_dynamic(void)
 	get_random_bytes(&timeout, sizeof(timeout));
 	timeout = CONF_BASE_TIMEOUT + (timeout % (unsigned int) CONF_TIMEOUT_RANDOM);
 	for (;;) {
+#ifdef IPCONFIG_BOOTP
 		/* Track the device we are configuring */
 		ic_dev_xid = d->xid;
 
-#ifdef IPCONFIG_BOOTP
 		if (do_bootp && (d->able & IC_BOOTP))
 			ic_bootp_send_if(d, jiffies - start_jiffies);
 #endif
-- 
1.7.11.7
