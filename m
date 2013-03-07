From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/2] tunnel: Inherit NETIF_F_SG for hw_enc_features.
Date: Thu,  7 Mar 2013 11:28:08 -0800
Message-ID: <1362684488-1822-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:36266 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933225Ab3CGT0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 14:26:36 -0500
Received: by mail-oa0-f70.google.com with SMTP id h2so5260643oag.5
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 11:26:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inherit scatergather feature for tunnel devices to avoid
copy for TSO packets of tunneling device like GRE.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/core/dev.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index bb99993..90cee5b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5205,6 +5205,10 @@ int register_netdevice(struct net_device *dev)
 	 */
 	dev->vlan_features |= NETIF_F_HIGHDMA;
 
+	/* Make NETIF_F_SG inheritable to tunnel devices.
+	 */
+	dev->hw_enc_features |= NETIF_F_SG;
+
 	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
 	ret = notifier_to_errno(ret);
 	if (ret)
-- 
1.7.1
