From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 1/4] net: phy: Export phy_stop_machine()
Date: Wed, 25 Oct 2017 16:21:21 -0700
Message-ID: <20171025232124.14120-2-f.fainelli@gmail.com>
References: <20171025232124.14120-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        andrew@lunn.ch, opendmb@gmail.com,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        slash.tmp@free.fr, david.daney@cavium.com, geert+renesas@glider.be
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:50793 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbdJYXVk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 19:21:40 -0400
Received: by mail-qt0-f193.google.com with SMTP id d9so2168767qtd.7
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 16:21:39 -0700 (PDT)
In-Reply-To: <20171025232124.14120-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_stop_machine() is publicly exported in include/linux/phy.y, and is
not made static because it's also used by phy_device.c. Since
phy_start_machine() is already exported, do this here too. This is a
function that provides hard guarantees that the state machine is
properly stopped past that synchronization point.

Fixes: 00db8189d984 ("This patch adds a PHY Abstraction Layer to the Linux Kernel, enabling ethernet drivers to remain as ignorant as is reasonable of the connected PHY's design and operation details.")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 2b1e67bc1e73..0ddeb97217ce 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -595,6 +595,7 @@ void phy_stop_machine(struct phy_device *phydev)
 		phydev->state = PHY_UP;
 	mutex_unlock(&phydev->lock);
 }
+EXPORT_SYMBOL_GPL(phy_stop_machine);
 
 /**
  * phy_error - enter HALTED state for this PHY device
-- 
2.9.3
