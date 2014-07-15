From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/3] bonding: use rcu_access_pointer() in bonding_show_mii_status()
Date: Tue, 15 Jul 2014 02:46:43 -0700
Message-ID: <1405417604-7828-3-git-send-email-edumazet@google.com>
References: <1405417604-7828-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:38222 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758410AbaGOJqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 05:46:51 -0400
Received: by mail-yh0-f73.google.com with SMTP id f73so867722yha.0
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 02:46:51 -0700 (PDT)
In-Reply-To: <1405417604-7828-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

curr_active_slave is rcu protected, and bonding_show_mii_status() only
wants to check if pointer is NULL or not.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/bonding/bond_sysfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index daed52f68ce1..98db8edd9c75 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -492,8 +492,9 @@ static ssize_t bonding_show_mii_status(struct device *d,
 				       char *buf)
 {
 	struct bonding *bond = to_bond(d);
+	bool active = !!rcu_access_pointer(bond->curr_active_slave);
 
-	return sprintf(buf, "%s\n", bond->curr_active_slave ? "up" : "down");
+	return sprintf(buf, "%s\n", active ? "up" : "down");
 }
 static DEVICE_ATTR(mii_status, S_IRUGO, bonding_show_mii_status, NULL);
 
-- 
2.0.0.526.g5318336
