From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH v3] bonding: make arp_ip_target parameter checks consistent with sysfs
Date: Thu, 29 Nov 2012 12:34:06 +0100
Message-ID: <1354188846-15577-1-git-send-email-nikolay@redhat.com>
References: <1354121052-6263-1-git-send-email-nikolay@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5991 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752645Ab2K2LgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 06:36:08 -0500
In-Reply-To: <1354121052-6263-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 The module can be loaded with arp_ip_target="255.255.255.255" which makes
 it impossible to remove as the function in sysfs checks for that value,
 so we make the parameter checks consistent with sysfs.

 v2: Fix formatting
 v3: Make description text < 75 columns

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5f5b69f..d29159a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4706,12 +4706,13 @@ static int bond_check_params(struct bond_params *params)
 	     arp_ip_count++) {
 		/* not complete check, but should be good enough to
 		   catch mistakes */
-		if (!isdigit(arp_ip_target[arp_ip_count][0])) {
+		__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
+		if (!isdigit(arp_ip_target[arp_ip_count][0]) ||
+		    ip == 0 || ip == htonl(INADDR_BROADCAST)) {
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
