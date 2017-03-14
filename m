From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] net:  Resend IGMP memberships upon peer notification.
Date: Tue, 14 Mar 2017 08:58:08 -0400
Message-ID: <1489496288-24139-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33160 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751087AbdCNM6X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 08:58:23 -0400
Received: by mail-qk0-f195.google.com with SMTP id j127so40998606qke.0
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 05:58:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we notify peers of potential changes,  it's also good to update
IGMP memberships.  For example, during VM migration, updating IGMP
memberships will redirect existing multicast streams to the VM at the
new location.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/core/dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index a229bf0..1ed927d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1272,6 +1272,7 @@ void netdev_notify_peers(struct net_device *dev)
 {
 	rtnl_lock();
 	call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, dev);
+	call_netdevice_notifiers(NETDEV_RESEND_IGMP, dev);
 	rtnl_unlock();
 }
 EXPORT_SYMBOL(netdev_notify_peers);
-- 
2.7.4
