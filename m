From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/igbvf/netdev.c: use %pM to shown MAC address
Date: Mon, 28 Dec 2009 17:35:04 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F4BE@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og101.obsmtp.com ([64.18.1.181]:34579 "HELO
	exprod6og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751253AbZL1WfA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 17:35:00 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index e9dd95f..1326232 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2608,11 +2608,7 @@ static void igbvf_print_device_info(struct igbvf_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 
 	dev_info(&pdev->dev, "Intel(R) 82576 Virtual Function\n");
-	dev_info(&pdev->dev, "Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
-	         /* MAC address */
-	         netdev->dev_addr[0], netdev->dev_addr[1],
-	         netdev->dev_addr[2], netdev->dev_addr[3],
-	         netdev->dev_addr[4], netdev->dev_addr[5]);
+	dev_info(&pdev->dev, "Address: %pM\n", netdev->dev_addr);
 	dev_info(&pdev->dev, "MAC: %d\n", hw->mac.type);
 }
 
@@ -2777,11 +2773,8 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
-		dev_err(&pdev->dev, "Invalid MAC Address: "
-		        "%02x:%02x:%02x:%02x:%02x:%02x\n",
-		        netdev->dev_addr[0], netdev->dev_addr[1],
-		        netdev->dev_addr[2], netdev->dev_addr[3],
-		        netdev->dev_addr[4], netdev->dev_addr[5]);
+		dev_err(&pdev->dev, "Invalid MAC Address: %pM\n",
+		        netdev->dev_addr);
 		err = -EIO;
 		goto err_hw_init;
 	} 
