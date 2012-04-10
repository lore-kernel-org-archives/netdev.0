From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Tue, 10 Apr 2012 09:26:23 -0400 (EDT)
Message-ID: <20120410.092623.821622563087500166.davem@davemloft.net>
References: <20120410152923.15aee4df478d819f167cd4af@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, msink@permonline.ru,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120410152923.15aee4df478d819f167cd4af@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 10 Apr 2012 15:29:23 +1000

> After merging the final tree, today's linux-next build (s390 allmodconfig)
> failed like this:

I just checked in the following which will hopefully cure this,
thanks:

--------------------
wiznet: Fix Kconfig dependencies.

Both drivers need to depend upon HAS_IOMEM, otherwise we
get a build failure on platforms like S390.

All the driver specific config options need to depend upon
the drivers themselves.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/wiznet/Kconfig |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/Kconfig b/drivers/net/ethernet/wiznet/Kconfig
index 2bb383c..c8291bf 100644
--- a/drivers/net/ethernet/wiznet/Kconfig
+++ b/drivers/net/ethernet/wiznet/Kconfig
@@ -19,6 +19,7 @@ if NET_VENDOR_WIZNET
 
 config WIZNET_W5100
 	tristate "WIZnet W5100 Ethernet support"
+	depends on HAS_IOMEM
 	---help---
 	  Support for WIZnet W5100 chips.
 
@@ -31,6 +32,7 @@ config WIZNET_W5100
 
 config WIZNET_W5300
 	tristate "WIZnet W5300 Ethernet support"
+	depends on HAS_IOMEM
 	---help---
 	  Support for WIZnet W5300 chips.
 
@@ -43,6 +45,7 @@ config WIZNET_W5300
 
 choice
 	prompt "WIZnet interface mode"
+	depends on WIZNET_W5100 || WIZNET_W5300
 	default WIZNET_BUS_ANY
 
 config WIZNET_BUS_DIRECT
@@ -69,6 +72,7 @@ endchoice
 
 config WIZNET_TX_FLOW
 	bool "Use transmit flow control"
+	depends on WIZNET_W5100 || WIZNET_W5300
 	default y
 	help
 	  This enables transmit flow control for WIZnet chips.
-- 
1.7.7.6
