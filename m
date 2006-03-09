From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] tg3.c:tg3_bus_string(): remove dead code
Date: Fri, 10 Mar 2006 00:06:50 +0100
Message-ID: <20060309230650.GJ21864@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750876AbWCIXGx@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted this dead code (note that (clock_ctrl == 7) 
is already handled above).


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc5-mm3-full/drivers/net/tg3.c.old	2006-03-09 23:25:25.000000000 +0100
+++ linux-2.6.16-rc5-mm3-full/drivers/net/tg3.c	2006-03-09 23:25:39.000000000 +0100
@@ -10596,26 +10596,24 @@ static char * __devinit tg3_bus_string(s
 		if ((clock_ctrl == 7) ||
 		    ((tr32(GRC_MISC_CFG) & GRC_MISC_CFG_BOARD_ID_MASK) ==
 		     GRC_MISC_CFG_BOARD_ID_5704CIOBE))
 			strcat(str, "133MHz");
 		else if (clock_ctrl == 0)
 			strcat(str, "33MHz");
 		else if (clock_ctrl == 2)
 			strcat(str, "50MHz");
 		else if (clock_ctrl == 4)
 			strcat(str, "66MHz");
 		else if (clock_ctrl == 6)
 			strcat(str, "100MHz");
-		else if (clock_ctrl == 7)
-			strcat(str, "133MHz");
 	} else {
 		strcpy(str, "PCI:");
 		if (tp->tg3_flags & TG3_FLAG_PCI_HIGH_SPEED)
 			strcat(str, "66MHz");
 		else
 			strcat(str, "33MHz");
 	}
 	if (tp->tg3_flags & TG3_FLAG_PCI_32BIT)
 		strcat(str, ":32-bit");
 	else
 		strcat(str, ":64-bit");
 	return str;
