From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] SolutionEngine7724: fix Ether support
Date: Sun, 18 Aug 2013 02:19:09 +0400
Message-ID: <201308180219.09528.sergei.shtylyov@cogentembedded.com>
References: <201308180213.23296.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org, davem@davemloft.net
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201308180213.23296.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Ether platform data is behind the declaration of 'struct sh_eth_plat_data'
as it's lacking the initializers for the 'register_type' and 'phy_interface'
fields -- it means they'll be implicitly and wrongly set to SH_ETH_REG_GIGABIT
and PHY_INTERFACE_MODE_NA. Initialize the fields explicitly and fix off-by-one
error in the Ether memory resource end, while at it...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: stable@vger.kernel.org

---
 arch/sh/boards/mach-se/7724/setup.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: net/arch/sh/boards/mach-se/7724/setup.c
===================================================================
--- net.orig/arch/sh/boards/mach-se/7724/setup.c
+++ net/arch/sh/boards/mach-se/7724/setup.c
@@ -365,7 +365,7 @@ static struct platform_device keysc_devi
 static struct resource sh_eth_resources[] = {
 	[0] = {
 		.start = SH_ETH_ADDR,
-		.end   = SH_ETH_ADDR + 0x1FC,
+		.end   = SH_ETH_ADDR + 0x1FC - 1,
 		.flags = IORESOURCE_MEM,
 	},
 	[1] = {
@@ -377,6 +377,8 @@ static struct resource sh_eth_resources[
 static struct sh_eth_plat_data sh_eth_plat = {
 	.phy = 0x1f, /* SMSC LAN8187 */
 	.edmac_endian = EDMAC_LITTLE_ENDIAN,
+	.register_type = SH_ETH_REG_FAST_SH4,
+	.phy_interace = PHY_INTERFACE_MODE_MII,
 };
 
 static struct platform_device sh_eth_device = {
