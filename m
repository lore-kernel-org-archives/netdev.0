From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] r8169: verbose mac address init
Date: Thu, 16 Oct 2008 23:47:09 +0200
Message-ID: <20081016214709.GB27208@electric-eye.fr.zoreil.com>
References: <20081016214555.GA27208@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>,
	Martin Capitanio <c4p7n@capitanio.org>,
	Petr Vandrovec <petr@vandrovec.name>,
	Plamen Petrov <pvp-lsts@fs.ru.acad.bg>,
	=?unknown-8bit?B?Si5BLiBNYWdhbGzDs24=?= <jamagallon@ono.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:53896 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755322AbYJPVrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 17:47:32 -0400
Content-Disposition: inline
In-Reply-To: <20081016214555.GA27208@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I prefer the debug information to be displayed until
the issue is properly handled.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c821da2..cd9a215 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1947,11 +1947,11 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 	u8 cfg1;
 	int vpd_cap;
 	u8 mac[8];
-	DECLARE_MAC_BUF(buf);
 
 	cfg1 = RTL_R8(Config1);
 	if (!(cfg1  & VPD)) {
-		dprintk("VPD access not enabled, enabling\n");
+		if (netif_msg_probe(tp))
+			dev_info(&pdev->dev, "VPD access disabled, enabling\n");
 		RTL_W8(Cfg9346, Cfg9346_Unlock);
 		RTL_W8(Config1, cfg1 | VPD);
 		RTL_W8(Cfg9346, Cfg9346_Lock);
@@ -1969,11 +1969,19 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 	 */
 	if (rtl_eeprom_read(pdev, vpd_cap, 0x000e, (__le32*)&mac[0]) < 0 ||
 	    rtl_eeprom_read(pdev, vpd_cap, 0x0012, (__le32*)&mac[4]) < 0) {
-		dprintk("Reading MAC address from EEPROM failed\n");
+		if (netif_msg_probe(tp)) {
+			dev_warn(&pdev->dev,
+				 "reading MAC address from EEPROM failed\n");
+		}
 		return;
 	}
 
-	dprintk("MAC address found in EEPROM: %s\n", print_mac(buf, mac));
+	if (netif_msg_probe(tp)) {
+		DECLARE_MAC_BUF(buf);
+
+		dev_info(&pdev->dev, "MAC address found in EEPROM: %s\n",
+			 print_mac(buf, mac));
+	}
 
 	/* Write MAC address */
 	rtl_rar_set(tp, mac);
-- 
1.5.3.3

