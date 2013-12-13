From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v6 9/11] bonding: remove unwanted lock for bond_option_active_slave_set()
Date: Fri, 13 Dec 2013 10:20:17 +0800
Message-ID: <52AA6EE1.1070200@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:19218 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615Ab3LMCVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 21:21:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_option_active_slave_set() is always called in RTNL,
the RTNL could protect bond slave list, so remove the unwanted
bond lock.

Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_options.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index ea6f640..479365e 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -106,7 +106,6 @@ int bond_option_active_slave_set(struct bonding *bond,
 	}
 
 	block_netpoll_tx();
-	read_lock(&bond->lock);
 	write_lock_bh(&bond->curr_slave_lock);
 
 	/* check to see if we are clearing active */
@@ -141,7 +140,6 @@ int bond_option_active_slave_set(struct bonding *bond,
 	}
 
 	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 	unblock_netpoll_tx();
 	return ret;
 }
-- 
1.8.0
