From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] et131x: Fix logical vs bitwise check in et131x_tx_timeout()
Date: Fri, 15 Jul 2016 16:40:22 -0700
Message-ID: <1468626024-31534-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	Mark Einon <mark.einon@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Antonio Quartulli <a@unstable.cc>,
	Felipe Balbi <felipe.balbi@linux.intel.com>,
	Florian Westphal <fw@strlen.de>, Insu Yun <wuninsu@gmail.com>,
	linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should be using a logical check here instead of a bitwise operation
to check if the device is closed already in et131x_tx_timeout().

Reported-by: coverity (CID 146498)
Fixes: 38df6492eb511 ("et131x: Add PCIe gigabit ethernet driver et131x to drivers/net")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/agere/et131x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index 30defe6c81f2..821d86c38ab2 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -3851,7 +3851,7 @@ static void et131x_tx_timeout(struct net_device *netdev)
 	unsigned long flags;
 
 	/* If the device is closed, ignore the timeout */
-	if (~(adapter->flags & FMP_ADAPTER_INTERRUPT_IN_USE))
+	if (!(adapter->flags & FMP_ADAPTER_INTERRUPT_IN_USE))
 		return;
 
 	/* Any nonrecoverable hardware error?
-- 
2.7.4
