From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] r8169: incorrect args to oob notify
Date: Wed, 23 Feb 2011 09:52:37 -0800
Message-ID: <20110223095237.0ee9c130@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52953 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380Ab1BWRwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 12:52:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sparse detected this bug. The function oob_notify was being
passed the private ptr, but expected to get the ioaddr.
Compile checked only; not tested on real hardware.

Patch against net-next-2.6 but should be applied to net-2.6.
Bug not present in 2.6.37 and earlier.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/r8169.c	2011-02-23 09:46:30.042289776 -0800
+++ b/drivers/net/r8169.c	2011-02-23 09:48:00.167355773 -0800
@@ -617,8 +617,9 @@ static void ocp_write(struct rtl8169_pri
 	}
 }
 
-static void rtl8168_oob_notify(void __iomem *ioaddr, u8 cmd)
+static void rtl8168_oob_notify(struct rtl8169_private *tp, u8 cmd)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
 	RTL_W8(ERIDR, cmd);
@@ -630,7 +631,7 @@ static void rtl8168_oob_notify(void __io
 			break;
 	}
 
-	ocp_write(ioaddr, 0x1, 0x30, 0x00000001);
+	ocp_write(tp, 0x1, 0x30, 0x00000001);
 }
 
 #define OOB_CMD_RESET		0x00
