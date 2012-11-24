From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH] bonding: make arp_ip_target parameter checks consistent with sysfs
Date: Sat, 24 Nov 2012 13:21:15 +0100
Message-ID: <1353759675-30511-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58379 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951Ab2KXMXV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Nov 2012 07:23:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 The module can be loaded with arp_ip_target="255.255.255.255" which makes it
 impossible to remove as the function in sysfs checks for that value, so we make
 the parameter checks consistent with sysfs.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5f5b69f..940eac8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4706,12 +4706,14 @@ static int bond_check_params(struct bond_params *params)
 	     arp_ip_count++) {
 		/* not complete check, but should be good enough to
 		   catch mistakes */
-		if (!isdigit(arp_ip_target[arp_ip_count][0])) {
+		__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
+		if (!isdigit(arp_ip_target[arp_ip_count][0])
+		    || ip == 0
+		    || ip == htonl(INADDR_BROADCAST)) {
 			pr_warning("Warning: bad arp_ip_target module parameter (%s), ARP monitoring will not be performed\n",
 				   arp_ip_target[arp_ip_count]);
 			arp_interval = 0;
 		} else {
-			__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
 			arp_target[arp_ip_count] = ip;
 		}
 	}
-- 
1.7.11.7
