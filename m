From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH RESEND net-next v3 2/2] bonding: fail_over_mac should only
 affect AB mode in bond_set_mac_address()
Date: Sat, 25 Jan 2014 13:00:57 +0800
Message-ID: <52E34509.3050002@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:3223 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbaAYFBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 00:01:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fail_over_mac could be set to active or follow in any time for all modes,
so if the fail_over_mac is not none and the current mode is not active-backup,
the bond_set_mac_address() could not change the master and slave's MAC address.

In bond_set_mac_address(), the fail_over_mac should only affect AB mode, so modify
to check the mode in addition to fail_over_mac when setting bond's MAC address.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4409aa8..4a79585 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3423,7 +3423,8 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	/* If fail_over_mac is enabled, do nothing and return success.
 	 * Returning an error causes ifenslave to fail.
 	 */
-	if (bond->params.fail_over_mac)
+	if (bond->params.fail_over_mac &&
+	    bond->params.mode == BOND_MODE_ACTIVEBACKUP)
 		return 0;
 
 	if (!is_valid_ether_addr(sa->sa_data))
-- 
1.8.0
