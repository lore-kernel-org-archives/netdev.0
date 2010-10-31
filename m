From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] qlcnic: fix panic on load
Date: Sun, 31 Oct 2010 16:50:38 +0100
Message-ID: <1288540238.2660.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58551 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755937Ab0JaPuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 11:50:44 -0400
Received: by wwe15 with SMTP id 15so5212353wwe.1
        for <netdev@vger.kernel.org>; Sun, 31 Oct 2010 08:50:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its now illegal to call netif_stop_queue() before register_netdev()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 7a298cd..a3dcd04 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1450,7 +1450,6 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	netdev->irq = adapter->msix_entries[0].vector;
 
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
 
 	err = register_netdev(netdev);
 	if (err) {


