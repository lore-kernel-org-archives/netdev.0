From: Joe Perches <joe@perches.com>
Subject: [PATCH 41/62] smc-ultra: Use static const
Date: Sat, 20 Nov 2010 18:38:42 -0800
Message-ID: <936f7f2182d553e5f3598c8d7a2152c946c9a0fb.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   5316	    112	   1176	   6604	   19cc	drivers/net/smc-ultra.o.new
   5302	    112	   1176	   6590	   19be	drivers/net/smc-ultra.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/smc-ultra.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/smc-ultra.c b/drivers/net/smc-ultra.c
index d2dd8e6..235a3c6 100644
--- a/drivers/net/smc-ultra.c
+++ b/drivers/net/smc-ultra.c
@@ -277,8 +277,12 @@ static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 	dev->base_addr = ioaddr+ULTRA_NIC_OFFSET;
 
 	{
-		int addr_tbl[4] = {0x0C0000, 0x0E0000, 0xFC0000, 0xFE0000};
-		short num_pages_tbl[4] = {0x20, 0x40, 0x80, 0xff};
+		static const int addr_tbl[4] = {
+			0x0C0000, 0x0E0000, 0xFC0000, 0xFE0000
+		};
+		static const short num_pages_tbl[4] = {
+			0x20, 0x40, 0x80, 0xff
+		};
 
 		dev->mem_start = ((addr & 0x0f) << 13) + addr_tbl[(addr >> 6) & 3] ;
 		num_pages = num_pages_tbl[(addr >> 4) & 3];
-- 
1.7.3.2.245.g03276.dirty
