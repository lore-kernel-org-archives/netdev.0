From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] e1000e: check_polarity function pointers not
	set for 8257x
Date: Wed, 02 Dec 2009 19:02:14 -0800
Message-ID: <20091203030213.2604.86948.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:33416
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754153AbZLCDCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 22:02:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The function pointers for 8257x devices are not set.  This is not really a
problem now because there is nothing in the driver that references the
pointers for this particular MAC-family (the appropriate functions are
called directly), but the pointers should be set in case they are used in
the future.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c  |    3 +++
 drivers/net/e1000e/es2lan.c |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index f6f3a22..c1a42cf 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1714,6 +1714,7 @@ static struct e1000_mac_operations e82571_mac_ops = {
 
 static struct e1000_phy_operations e82_phy_ops_igp = {
 	.acquire		= e1000_get_hw_semaphore_82571,
+	.check_polarity		= e1000_check_polarity_igp,
 	.check_reset_block	= e1000e_check_reset_block_generic,
 	.commit			= NULL,
 	.force_speed_duplex	= e1000e_phy_force_speed_duplex_igp,
@@ -1731,6 +1732,7 @@ static struct e1000_phy_operations e82_phy_ops_igp = {
 
 static struct e1000_phy_operations e82_phy_ops_m88 = {
 	.acquire		= e1000_get_hw_semaphore_82571,
+	.check_polarity		= e1000_check_polarity_m88,
 	.check_reset_block	= e1000e_check_reset_block_generic,
 	.commit			= e1000e_phy_sw_reset,
 	.force_speed_duplex	= e1000e_phy_force_speed_duplex_m88,
@@ -1748,6 +1750,7 @@ static struct e1000_phy_operations e82_phy_ops_m88 = {
 
 static struct e1000_phy_operations e82_phy_ops_bm = {
 	.acquire		= e1000_get_hw_semaphore_82571,
+	.check_polarity		= e1000_check_polarity_m88,
 	.check_reset_block	= e1000e_check_reset_block_generic,
 	.commit			= e1000e_phy_sw_reset,
 	.force_speed_duplex	= e1000e_phy_force_speed_duplex_m88,
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index c7bc657..d2a1047 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1391,6 +1391,7 @@ static struct e1000_mac_operations es2_mac_ops = {
 
 static struct e1000_phy_operations es2_phy_ops = {
 	.acquire		= e1000_acquire_phy_80003es2lan,
+	.check_polarity		= e1000_check_polarity_m88,
 	.check_reset_block	= e1000e_check_reset_block_generic,
 	.commit		 	= e1000e_phy_sw_reset,
 	.force_speed_duplex 	= e1000_phy_force_speed_duplex_80003es2lan,

