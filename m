From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net RESEND] bonding: add ip checks when store ip target
Date: Wed, 13 Nov 2013 10:19:02 +0800
Message-ID: <5282E196.8030401@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:63812 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737Ab3KMCVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 21:21:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I met a Bug when I add ip target with the wrong ip address:

echo +500.500.500.500 > /sys/class/net/bond0/bonding/arp_ip_target

the wrong ip address will transfor to 245.245.245.244 and add
to the ip target success, it is uncorrect, so I add checks to avoid
adding wrong address.

The in4_pton() will set wrong ip address to 0.0.0.0, it will return by
the next check and will not add to ip target.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ec9b646..e0c97fb 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -653,7 +653,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 	int ind, i, j, ret = -EINVAL;
 
 	targets = bond->params.arp_targets;
-	newtarget = in_aton(buf + 1);
+	in4_pton(buf + 1, strlen(buf) - 1, (u8 *)&newtarget, -1, NULL);
 	/* look for adds */
 	if (buf[0] == '+') {
 		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-- 
1.8.0
