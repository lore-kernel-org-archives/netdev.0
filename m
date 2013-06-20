From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 2/6] bonding: don't add duplicate targets to arp_ip_target
Date: Thu, 20 Jun 2013 18:35:01 +0200
Message-ID: <1371746105-2482-3-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com, nikolay@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161031Ab3FTQe7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 12:34:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print a warning and skip them.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 976d28e..1645130 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4588,7 +4588,11 @@ static int bond_check_params(struct bond_params *params)
 				   arp_ip_target[i]);
 			arp_interval = 0;
 		} else {
-			arp_target[arp_ip_count++] = ip;
+			if (bond_get_targets_ip(arp_target, ip) == -1)
+				arp_target[arp_ip_count++] = ip;
+			else
+				pr_warning("Warning: duplicate address %pI4 in arp_ip_target, skipping\n",
+					   &ip);
 		}
 	}
 
-- 
1.7.1
