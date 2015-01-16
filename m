From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH net-next 2/5] bonding: fix bond_open() don't always set slave active flag
Date: Fri, 16 Jan 2015 10:57:25 -0500
Message-ID: <1421423848-414-3-git-send-email-jtoppins@cumulusnetworks.com>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>,
	Jonathan Toppins <jtoppins@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:58752 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbAPP5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 10:57:43 -0500
Received: by mail-qg0-f49.google.com with SMTP id f51so16821135qge.8
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 07:57:42 -0800 (PST)
In-Reply-To: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wilson Kok <wkok@cumulusnetworks.com>

Mode 802.3ad, fix incorrect bond slave active state when slave is not in
active aggregator. During bond_open(), the bonding driver always sets
the slave active flag to true if the bond is not in active-backup, alb,
or tlb modes. Bonding should let the aggregator selection logic set the
active flag when in 802.3ad mode.

Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 02ffedb..c475d90 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3066,7 +3066,7 @@ static int bond_open(struct net_device *bond_dev)
 			    slave != rcu_access_pointer(bond->curr_active_slave)) {
 				bond_set_slave_inactive_flags(slave,
 							      BOND_SLAVE_NOTIFY_NOW);
-			} else {
+			} else if (BOND_MODE(bond) != BOND_MODE_8023AD) {
 				bond_set_slave_active_flags(slave,
 							    BOND_SLAVE_NOTIFY_NOW);
 			}
-- 
1.7.10.4
