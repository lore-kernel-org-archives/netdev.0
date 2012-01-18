From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [REGRESSION] fix smsc911x build failure due to "net/smsc911x:
	Check if PHY is in operational mode before software reset"
Date: Wed, 18 Jan 2012 17:36:12 +0000
Message-ID: <20120118173612.GM1068@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Javier Martinez Canillas <javier@dowhile0.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:54175 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301Ab2ARRg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 12:36:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>

Commit 6386994e03ebbe (net/smsc911x: Check if PHY is in operational
mode before software reset) causes the following build errors with
ARM Versatile Express:

drivers/net/ethernet/smsc/smsc911x.c: In function 'smsc911x_phy_disable_energy_detect':
drivers/net/ethernet/smsc/smsc911x.c:1329: error: 'MII_LAN83C185_CTRL_STATUS' undeclared (first use in this function)
drivers/net/ethernet/smsc/smsc911x.c:1329: error: (Each undeclared identifier is reported only once
drivers/net/ethernet/smsc/smsc911x.c:1329: error: for each function it appears in.)
drivers/net/ethernet/smsc/smsc911x.c:1340: error: 'MII_LAN83C185_EDPWRDOWN' undeclared (first use in this function)
drivers/net/ethernet/smsc/smsc911x.c:1341: error: 'MII_LAN83C185_ENERGYON' undeclared (first use in this function)
drivers/net/ethernet/smsc/smsc911x.c: In function 'smsc911x_phy_enable_energy_detect':
drivers/net/ethernet/smsc/smsc911x.c:1364: error: 'MII_LAN83C185_CTRL_STATUS' undeclared (first use in this function)
drivers/net/ethernet/smsc/smsc911x.c:1372: error: 'MII_LAN83C185_EDPWRDOWN' undeclared (first use in this function)

Adding linux/smscphy.h solves this build error.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
--
 drivers/net/ethernet/smsc/smsc911x.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 9d0b8ce..9aeb666 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -54,6 +54,7 @@
 #include <linux/swab.h>
 #include <linux/phy.h>
 #include <linux/smsc911x.h>
+#include <linux/smscphy.h>
 #include <linux/device.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
