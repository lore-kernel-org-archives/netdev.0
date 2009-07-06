From: "Sonasath, Moiz" <m-sonasath@ti.com>
Subject: [PATCH] [RFC] Potential bug in defining 'irq field' of 'ifmap
 structure'
Date: Mon, 6 Jul 2009 17:23:36 -0500
Message-ID: <CD8CC2B65FEE304DA95744A5472698F202952C3124@dlee06.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"Pandita, Vikram" <vikram.pandita@ti.com>
To: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Moiz Sonasath <m-sonasath@ti.com>

There seems to be a bug in the ioctl implementation in /kernel/net/core/dev.c 
 
dev_ifsioc_locked()
	case SIOCGIFMAP:
			ifr->ifr_map.irq = dev->irq;   // ?? type mismatch

Here
ifr->ifr_map.irq) is of type unsigned char
dev-irq is of type unsigned int

So ifconfig reports a wrong irq number when the dev->irq number is > 255.

I am confused to see the same typedefs in file: net/if.h 
Not sure how to make changes for the user side net/if.h file?

Signed-off-by: Moiz Sonasath <m-sonasath@ti.com>
Signed-off-by: Vikram Pandita <vikram.pandita@ti.com>
	
---
 include/linux/if.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/if.h b/include/linux/if.h
index 2d89c96..1ac6559 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -126,7 +126,7 @@ struct ifmap
 	unsigned long mem_start;
 	unsigned long mem_end;
 	unsigned short base_addr;
-	unsigned char irq;
+	unsigned int irq;
 	unsigned char dma;
 	unsigned char port;
 	/* 3 bytes spare */
-- 
1.5.6.3

