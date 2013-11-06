From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 7/9] bonding: remove unwanted lock for bond_option_active_slave_set()
Date: Wed, 6 Nov 2013 14:53:04 +0800
Message-ID: <5279E750.8060400@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:59334 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568Ab3KFGyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 01:54:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_option_active_slave_set() is always in RTNL, bond lock
and curr_slave_lock is no longer need here, so remove it to clean
the function.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_options.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 9a5223c..7694343 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -101,8 +101,6 @@ int bond_option_active_slave_set(struct bonding *bond,
 	}
 
 	block_netpoll_tx();
-	read_lock(&bond->lock);
-	write_lock_bh(&bond->curr_slave_lock);
 
 	/* check to see if we are clearing active */
 	if (!slave_dev) {
@@ -135,8 +133,6 @@ int bond_option_active_slave_set(struct bonding *bond,
 		}
 	}
 
-	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 	unblock_netpoll_tx();
 	return ret;
 }
-- 
1.8.2.1
