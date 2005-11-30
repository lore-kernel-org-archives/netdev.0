From: Magnus Damm <magnus@valinux.co.jp>
Subject: [PATCH] i82596/CONFIG_APRICOT release_region() fix
Date: Wed, 30 Nov 2005 16:23:45 +0900 (JST)
Message-ID: <20051130072604.7030.49055.sendpatchset@cherry.local>
Cc: Magnus Damm <magnus@valinux.co.jp>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix release_region() in i82596 driver using CONFIG_APRICOT.

linux-2.6.15-rc3 configured with CONFIG_APRICOT=y calls release_region()
incorrectly if no hardware is found:

Trying to free nonexistent resource <00000000-00000010>

This patch sets up dev->base_addr before the label "out1" might be used.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 82596.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

--- linux-2.6.15-rc3/drivers/net/82596.c	2005-11-30 16:10:34.000000000 +0900
+++ linux-2.6.15-rc3-i82596_apricot_release_region/drivers/net/82596.c	2005-11-30 16:11:13.000000000 +0900
@@ -1203,6 +1203,9 @@
 			checksum += eth_addr[i];
 		}
 
+		dev->base_addr = ioaddr;
+		dev->irq = 10;
+
 		/* checksum is a multiple of 0x100, got this wrong first time
 		   some machines have 0x100, some 0x200. The DOS driver doesn't
 		   even bother with the checksum.
@@ -1215,8 +1218,6 @@
 			goto out1;
 		}
 
-		dev->base_addr = ioaddr;
-		dev->irq = 10;
 	}
 #endif
 	dev->mem_start = (int)__get_free_pages(GFP_ATOMIC, 0);
