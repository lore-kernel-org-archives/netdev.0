From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6] bonding: reduce noise during init
Date: Tue, 26 Jul 2011 17:35:07 -0400
Message-ID: <1311716107-12328-1-git-send-email-andy@greyhouse.net>
Cc: fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844Ab1GZVcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2011 17:32:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many are using sysfs to configure bonding rather than module options, so
there is no need for bonding to throw this warning in normal cases.

Keep the message around when debugging is enabled as it might be useful
for someone desperate enough to enable debugging, but eliminate it
otherwise.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/bonding/bond_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 61265f7..5ca23b1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4745,7 +4745,10 @@ static int bond_check_params(struct bond_params *params)
 		/* miimon and arp_interval not set, we need one so things
 		 * work as expected, see bonding.txt for details
 		 */
-		pr_warning("Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.\n");
+		pr_debug("Warning: either miimon or arp_interval and"
+			 " arp_ip_target module parameters must be specified,"
+			 " otherwise bonding will not detect link failures!"
+			 "  See bonding.txt for details.\n");
 	}
 
 	if (primary && !USES_PRIMARY(bond_mode)) {
-- 
1.7.4.4

