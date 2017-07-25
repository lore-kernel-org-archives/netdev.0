From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] bonding: commit link status change after propose
Date: Tue, 25 Jul 2017 09:44:25 -0700
Message-ID: <20170725164425.9112-1-xiyou.wangcong@gmail.com>
Cc: benjamin.gilbert@coreos.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:38697 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdGYQou (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 12:44:50 -0400
Received: by mail-pf0-f195.google.com with SMTP id c23so13304339pfe.5
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 09:44:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit de77ecd4ef02 ("bonding: improve link-status update in mii-monitoring")
moves link status commitment into bond_mii_monitor(), but it still relies
on the return value of bond_miimon_inspect() as the hint. We need to return
non-zero as long as we propose a link status change.

Fixes: de77ecd4ef02 ("bonding: improve link-status update in mii-monitoring")
Reported-by: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Tested-by: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Cc: Mahesh Bandewar <maheshb@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/bonding/bond_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 181839d6fbea..9bee6c1c70cc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2050,6 +2050,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 				continue;
 
 			bond_propose_link_state(slave, BOND_LINK_FAIL);
+			commit++;
 			slave->delay = bond->params.downdelay;
 			if (slave->delay) {
 				netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
@@ -2088,6 +2089,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 				continue;
 
 			bond_propose_link_state(slave, BOND_LINK_BACK);
+			commit++;
 			slave->delay = bond->params.updelay;
 
 			if (slave->delay) {
-- 
2.13.0
