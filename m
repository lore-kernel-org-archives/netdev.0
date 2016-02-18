From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Unregister slave_dev in error path
Date: Wed, 17 Feb 2016 18:19:11 -0800
Message-ID: <1455761951-26408-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, opendmb@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34808 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422762AbcBRCTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 21:19:21 -0500
Received: by mail-pa0-f45.google.com with SMTP id fy10so21608097pac.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 18:19:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit 0071f56e46da ("dsa: Register netdev before phy"), we are now trying
to unregister a network device that has been previously registered, and in case
of errors, this will make us hit the BUG_ON(dev->reg_state !=
NETREG_UNREGISTERED) condition.

Fix this by adding a missing unregister_netdev() before free_netdev().

Fixes: 0071f56e46da ("dsa: Register netdev before phy")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 40b9ca7..e685042 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1205,6 +1205,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	ret = dsa_slave_phy_setup(p, slave_dev);
 	if (ret) {
 		netdev_err(master, "error %d setting up slave phy\n", ret);
+		unregister_netdev(slave_dev);
 		free_netdev(slave_dev);
 		return ret;
 	}
-- 
1.7.1
