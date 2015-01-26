From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/5] bonding: fix bond_open() don't always set slave active flag
Date: Mon, 26 Jan 2015 01:16:58 -0500
Message-ID: <1422253021-3798-3-git-send-email-jtoppins@cumulusnetworks.com>
References: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, Wilson Kok <wkok@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:61287 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbbAZGUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 01:20:16 -0500
Received: by mail-qc0-f181.google.com with SMTP id l6so5643646qcy.12
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 22:20:16 -0800 (PST)
In-Reply-To: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wilson Kok <wkok@cumulusnetworks.com>

Mode 802.3ad, fix incorrect bond slave active state when slave is not in
active aggregator. During bond_open(), the bonding driver always sets
the slave active flag to true if the bond is not in active-backup, alb,
or tlb modes. Bonding should let the aggregator selection logic set the
active flag when in 802.3ad mode.

Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
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
