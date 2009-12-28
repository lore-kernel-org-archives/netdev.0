From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/usb/rtl8150.c: use %pM to shown MAC address
Date: Mon, 28 Dec 2009 18:27:27 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F4CC@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og103.obsmtp.com ([64.18.1.185]:56487 "HELO
	exprod6og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751975AbZL1X1X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 18:27:23 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index f14d225..dfc7e9f 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -313,20 +313,17 @@ static int rtl8150_set_mac_address(struct net_device *netdev, void *p)
 {
 	struct sockaddr *addr = p;
 	rtl8150_t *dev = netdev_priv(netdev);
-	int i;
 
 	if (netif_running(netdev))
 		return -EBUSY;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	dbg("%s: Setting MAC address to ", netdev->name);
-	for (i = 0; i < 5; i++)
-		dbg("%02X:", netdev->dev_addr[i]);
-	dbg("%02X\n", netdev->dev_addr[i]);
+	dbg("%s: Setting MAC address to %pM\n", netdev->name, netdev->dev_addr);
 	/* Set the IDR registers. */
 	set_registers(dev, IDR, netdev->addr_len, netdev->dev_addr);
 #ifdef EEPROM_WRITE
 	{
+	int i;
 	u8 cr;
 	/* Get the CR contents. */
 	get_registers(dev, CR, 1, &cr); 
