From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 3/5] bonding: Initialize the ALB work queue for lb mode only.
Date: Fri, 28 Mar 2014 22:29:06 -0700
Message-ID: <1396070946-17650-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:51935 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbaC2F3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 01:29:08 -0400
Received: by mail-ie0-f201.google.com with SMTP id rd18so1237961iec.0
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 22:29:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

micro change to initialize / cancel the ALB work queue only
if the mode selected is ALB or TLB.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 06024abcffcf..e4f062ddc23e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3046,7 +3046,8 @@ static void bond_work_init_all(struct bonding *bond)
 {
 	INIT_DELAYED_WORK(&bond->mcast_work,
 			  bond_resend_igmp_join_requests_delayed);
-	INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
+	if (bond_is_lb(bond))
+		INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
 	INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
 	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
 		INIT_DELAYED_WORK(&bond->arp_work, bond_activebackup_arp_mon);
@@ -3059,7 +3060,8 @@ static void bond_work_cancel_all(struct bonding *bond)
 {
 	cancel_delayed_work_sync(&bond->mii_work);
 	cancel_delayed_work_sync(&bond->arp_work);
-	cancel_delayed_work_sync(&bond->alb_work);
+	if (bond_is_lb(bond))
+		cancel_delayed_work_sync(&bond->alb_work);
 	cancel_delayed_work_sync(&bond->ad_work);
 	cancel_delayed_work_sync(&bond->mcast_work);
 }
-- 
1.9.1.423.g4596e3a
