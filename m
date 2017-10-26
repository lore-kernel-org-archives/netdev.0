From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 06/14] bnxt_en: Optimize .ndo_set_mac_address() for VFs.
Date: Thu, 26 Oct 2017 11:51:24 -0400
Message-ID: <1509033092-1887-7-git-send-email-michael.chan@broadcom.com>
References: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:45909 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932430AbdJZPvw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:51:52 -0400
Received: by mail-qt0-f193.google.com with SMTP id p1so4883232qtg.2
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:51:52 -0700 (PDT)
In-Reply-To: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to call bnxt_approve_mac() which will send a message to the
PF if the MAC address hasn't changed.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index ffc6c49..ef5a5e5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7249,13 +7249,13 @@ static int bnxt_change_mac_addr(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	if (ether_addr_equal(addr->sa_data, dev->dev_addr))
+		return 0;
+
 	rc = bnxt_approve_mac(bp, addr->sa_data);
 	if (rc)
 		return rc;
 
-	if (ether_addr_equal(addr->sa_data, dev->dev_addr))
-		return 0;
-
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	if (netif_running(dev)) {
 		bnxt_close_nic(bp, false, false);
-- 
1.8.3.1
