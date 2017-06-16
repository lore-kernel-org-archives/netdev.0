From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net 1/4] macvlan: Do not return error when setting the same mac address
Date: Fri, 16 Jun 2017 09:36:46 -0400
Message-ID: <20170616133649.24622-2-vyasevic@redhat.com>
References: <20170616133649.24622-1-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35355 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753441AbdFPNg7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 09:36:59 -0400
Received: by mail-qt0-f193.google.com with SMTP id x58so10235103qtc.2
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 06:36:59 -0700 (PDT)
In-Reply-To: <20170616133649.24622-1-vyasevic@redhat.com>
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
