From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 3/6] bonding: don't add duplicate targets to arp_ip_target
Date: Wed, 19 Jun 2013 19:34:43 +0200
Message-ID: <1371663286-12518-4-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50081 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757183Ab3FSRfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 13:35:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print a warning and skip them.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 09a79eb..b69c7f0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4578,7 +4578,11 @@ static int bond_check_params(struct bond_params *params)
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
