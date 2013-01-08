From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] net: init perm_addr in register_netdevice()
Date: Tue,  8 Jan 2013 12:38:25 +0100
Message-ID: <1357645106-1976-2-git-send-email-jiri@resnulli.us>
References: <1357645106-1976-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	ebiederm@xmission.com, amwang@redhat.com, sassmann@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:48328 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755153Ab3AHLpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 06:45:12 -0500
Received: by mail-we0-f173.google.com with SMTP id z2so244962wey.4
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 03:45:11 -0800 (PST)
In-Reply-To: <1357645106-1976-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benefit from the fact that dev->addr_assign_type is set to NET_ADDR_PERM
in case the device has permanent address.

This also fixes the problem that many drivers do not set perm_addr at
all.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/dev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index a51ccf4..55f20d9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6003,6 +6003,13 @@ int register_netdevice(struct net_device *dev)
 	list_netdevice(dev);
 	add_device_randomness(dev->dev_addr, dev->addr_len);
 
+	/* If the device has permanent device address, driver should
+	 * set dev_addr and also addr_assign_type should be set to
+	 * NET_ADDR_PERM (default value).
+	 */
+	if (dev->addr_assign_type == NET_ADDR_PERM)
+		memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
+
 	/* Notify protocols, that a new device appeared. */
 	ret = call_netdevice_notifiers(NETDEV_REGISTER, dev);
 	ret = notifier_to_errno(ret);
-- 
1.8.1
