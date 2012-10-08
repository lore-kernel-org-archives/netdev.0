From: Graham Gower <graham.gower@gmail.com>
Subject: [PATCH v3] skge: Add DMA mask quirk for Marvell 88E8001 on ASUS P5NSLI
 motherboard.
Date: Mon, 08 Oct 2012 16:24:44 +1030
Message-ID: <50726AA4.7080901@gmail.com>
References: <50711961.1010101@gmail.com> <507265B8.5070406@gmail.com> <20121008.013635.1877246075568372072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:65153 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883Ab2JHFyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 01:54:45 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so3623670pad.19
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2012 22:54:45 -0700 (PDT)
In-Reply-To: <20121008.013635.1877246075568372072.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell 88E8001 on an ASUS P5NSLI motherboard is unable to send/receive
packets on a system with >4gb ram unless a 32bit DMA mask is used.

This issue has been around for years and a fix was sent 3.5 years ago, but
there was some debate as to whether it should instead be fixed as a PCI quirk.
http://www.spinics.net/lists/netdev/msg88670.html

However, 18 months later a similar workaround was introduced for another
chipset exhibiting the same problem.
http://www.spinics.net/lists/netdev/msg142287.html

Signed-off-by: Graham Gower <graham.gower@gmail.com>


--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -4143,6 +4143,13 @@
  			DMI_MATCH(DMI_BOARD_NAME, "nForce"),
  		},
  	},
+	{
+		.ident = "ASUS P5NSLI",
+		.matches = {
+			DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
+			DMI_MATCH(DMI_BOARD_NAME, "P5NSLI")
+		},
+	},
  	{}
  };
  
