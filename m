From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] bonding: fix packets_per_slave showing
Date: Thu,  5 Dec 2013 11:36:58 +0100
Message-ID: <1386239818-7408-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753801Ab3LEKoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 05:44:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's an issue when showing the value of packets_per_slave due to
using signed integer. The value may be < 0 and thus not put through
reciprocal_value() before showing. This patch makes it use unsigned
integer when showing it.

CC: Andy Gospodarek <andy@greyhouse.net>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Veaceslav Falico <vfalico@redhat.com>
CC: David S. Miller <davem@davemloft.net>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index abf5e10..0ae580b 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1635,12 +1635,12 @@ static ssize_t bonding_show_packets_per_slave(struct device *d,
 					      char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	int packets_per_slave = bond->params.packets_per_slave;
+	unsigned int packets_per_slave = bond->params.packets_per_slave;
 
 	if (packets_per_slave > 1)
 		packets_per_slave = reciprocal_value(packets_per_slave);
 
-	return sprintf(buf, "%d\n", packets_per_slave);
+	return sprintf(buf, "%u\n", packets_per_slave);
 }
 
 static ssize_t bonding_store_packets_per_slave(struct device *d,
-- 
1.8.1.4
