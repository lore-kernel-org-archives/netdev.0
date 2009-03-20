From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: linux-next: Tree for March 20 - dnet build break on s390
Date: Fri, 20 Mar 2009 10:14:01 +0100
Message-ID: <20090320101401.6ea261ea@osiris.boeblingen.de.ibm.com>
References: <20090320162800.24b0ad93.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	Ilya Yanok <yanok@emcraft.com>, netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090320162800.24b0ad93.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dnet: Dave DNET breaks an allyesconfig build on s390:

  CC      drivers/net/dnet.o
drivers/net/dnet.c: In function 'dnet_readw_mac':
drivers/net/dnet.c:36: error: implicit declaration of function 'writel'
drivers/net/dnet.c:43: error: implicit declaration of function 'readl'
drivers/net/dnet.c: In function 'dnet_probe':
drivers/net/dnet.c:873: error: implicit declaration of function 'ioremap'
drivers/net/dnet.c:873: warning: assignment makes pointer from integer without a cast
drivers/net/dnet.c:939: error: implicit declaration of function 'iounmap'

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-next/drivers/net/Kconfig
===================================================================
--- linux-next.orig/drivers/net/Kconfig
+++ linux-next/drivers/net/Kconfig
@@ -1042,7 +1042,7 @@ config NI65
 
 config DNET
 	tristate "Dave ethernet support (DNET)"
-	depends on NET_ETHERNET
+	depends on NET_ETHERNET && HAS_IOMEM
 	select PHYLIB
 	help
 	  The Dave ethernet interface (DNET) is found on Qong Board FPGA.
