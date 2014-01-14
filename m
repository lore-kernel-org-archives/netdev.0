From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next] bonding: don't permit slaves to change their mtu
Date: Tue, 14 Jan 2014 11:01:59 +0800
Message-ID: <52D4A8A7.60100@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:25191 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbaANDCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 22:02:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 2315dc91a5059d7da9a8b9b9daf78d695c11383e
(net: make dev_set_mtu() honor notification return code)
will deal with the return value for NETDEV_CHANGEMTU notification,
and the slaves should not change their mtu, so add return value
to prevent doing it.

Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e06c445..af4e678 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2846,19 +2846,11 @@ static int bond_slave_netdev_event(unsigned long event,
 		 */
 		break;
 	case NETDEV_CHANGEMTU:
-		/*
-		 * TODO: Should slaves be allowed to
-		 * independently alter their MTU?  For
-		 * an active-backup bond, slaves need
-		 * not be the same type of device, so
-		 * MTUs may vary.  For other modes,
-		 * slaves arguably should have the
-		 * same MTUs. To do this, we'd need to
-		 * take over the slave's change_mtu
-		 * function for the duration of their
-		 * servitude.
+		/* The master and slaves should have the
+		 * the same mtu, so do't permit slaves
+		 * to change their mtu independently.
 		 */
-		break;
+		return NOTIFY_BAD;
 	case NETDEV_CHANGENAME:
 		/*
 		 * TODO: handle changing the primary's name
-- 
1.8.0
