From: Graham Gower <graham.gower@gmail.com>
Subject: skge: Add DMA mask quirk for Marvell 88E8001 on ASUS P5NSLI motherboard.
Date: Sun, 07 Oct 2012 16:25:45 +1030
Message-ID: <50711961.1010101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36879 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750Ab2JGFzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 01:55:52 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so3038690pad.19
        for <netdev@vger.kernel.org>; Sat, 06 Oct 2012 22:55:52 -0700 (PDT)
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

--- skge.c.bak	2012-10-07 13:00:56.000000000 +1030
+++ skge.c	2012-10-07 13:26:03.000000000 +1030
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
  
