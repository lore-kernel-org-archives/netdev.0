From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v4 8/11] bonding: remove unwanted lock for bond_option_active_slave_set()
Date: Sat, 7 Dec 2013 15:45:59 +0800
Message-ID: <52A2D237.9070709@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:64728 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683Ab3LGHvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 02:51:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_option_active_slave_set() is always called in RTNL,
the RTNL could protect bond slave list enough, so remove the
unwanted bond lock.

Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_options.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 9a5223c..ae4cd04 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -101,7 +101,6 @@ int bond_option_active_slave_set(struct bonding *bond,
 	}
 
 	block_netpoll_tx();
-	read_lock(&bond->lock);
 	write_lock_bh(&bond->curr_slave_lock);
 
 	/* check to see if we are clearing active */
@@ -136,7 +135,6 @@ int bond_option_active_slave_set(struct bonding *bond,
 	}
 
 	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 	unblock_netpoll_tx();
 	return ret;
 }
-- 
1.8.2.1
