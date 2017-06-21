From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V2 net 1/4] macvlan: Do not return error when setting the same mac address
Date: Wed, 21 Jun 2017 07:59:16 -0400
Message-ID: <20170621115919.28165-2-vyasevic@redhat.com>
References: <20170621115919.28165-1-vyasevic@redhat.com>
Cc: girish.moodalbail@oracle.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34952 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbdFUL7a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 07:59:30 -0400
Received: by mail-qk0-f195.google.com with SMTP id 16so9736384qkg.2
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 04:59:30 -0700 (PDT)
In-Reply-To: <20170621115919.28165-1-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The user currently gets an EBUSY error when attempting to set
the mac address on a macvlan device to the same value.

This should really be a no-op as nothing changes.  Catch
the condition and return early.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 67bf7eb..de214fb 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -703,6 +703,10 @@ static int macvlan_set_mac_address(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	/* If the addresses are the same, this is a no-op */
+	if (ether_addr_equal(dev->dev_addr, addr->sa_data))
+		return 0;
+
 	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
 		dev_set_mac_address(vlan->lowerdev, addr);
 		return 0;
-- 
2.9.4
