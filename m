From: Liviu Dudau <Liviu.Dudau@arm.com>
Subject: [PATCH v2 net-next] sky2: use random address if EEPROM is bad
Date: Tue, 11 Aug 2015 15:35:56 +0100
Message-ID: <1439303756-30333-1-git-send-email-Liviu.Dudau@arm.com>
References: <55C2AB51.1040409@gmail.com>
Cc: Mirko Lindner <mlindner@marvell.com>,
	Ryan Harkin <ryan.harkin@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw-tnat.cambridge.arm.com ([217.140.96.140]:47190 "EHLO
	cam-smtp0.cambridge.arm.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965088AbbHKOgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 10:36:05 -0400
In-Reply-To: <55C2AB51.1040409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some embedded systems the EEPROM does not contain a valid MAC address.
In that case it is better to fallback to a generated mac address and
let init scripts fix the value later.

Reported-by: Liviu Dudau <Liviu.Dudau@arm.com>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
[Changed handcoded setup to use eth_hw_addr_random() instead]
Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>
---
I have tested this on my Juno platform and I can successfully do an nfsroot boot.

Best regards,
Liviu

 drivers/net/ethernet/marvell/sky2.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index d9f4498..c309879 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4819,6 +4819,13 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
 		memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8,
 			      ETH_ALEN);
 
+	/* if the address is invalid, use a random value */
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		netdev_warn(dev,
+			"Invalid MAC address, defaulting to random\n");
+		eth_hw_addr_random(dev);
+	}
+
 	return dev;
 }
 
-- 
2.4.6
