From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2] sh_eth: use random MAC address if no valid one supplied
Date: Mon, 29 Apr 2013 23:49:42 +0400
Message-ID: <201304292349.43251.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Renesas R-Car based development boards, although a MAC address is printed on
all the Ethernet port labels, U-Boot  doesn't write a valid MAC address  to the
Ether MAHR/MALR registers (there's no storage provided for the Ether MAC address
either), so we have to resort to using a random MAC address...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against the 'net-next.git' repository.

Changes since the original posting:
- don't break the message string into 2 lines.

 drivers/net/ethernet/renesas/sh_eth.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2735,6 +2735,11 @@ static int sh_eth_drv_probe(struct platf
 
 	/* read and set MAC address */
 	read_mac_address(ndev, pd->mac_addr);
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		dev_warn(&pdev->dev,
+			 "no valid MAC address supplied, using a random one.\n");
+		eth_hw_addr_random(ndev);
+	}
 
 	/* ioremap the TSU registers */
 	if (mdp->cd->tsu) {
