From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000e: swap max hw supported frame size between
	82574 and 82583
Date: Fri, 02 Oct 2009 15:30:42 -0700
Message-ID: <20091002223042.4191.43767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, rjw@sisk.pl,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:40406 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753047AbZJBWal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 18:30:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There appears to have been a mixup in the max supported jumbo frame size
between 82574 and 82583 which ended up disabling jumbo frames on the 82574
as a result.  This patch swaps the two so that this issue is resolved.

This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=14261

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index b53b40b..d1e0563 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1803,7 +1803,7 @@ struct e1000_info e1000_82574_info = {
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
 	.pba			= 20,
-	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
+	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_bm,
@@ -1820,7 +1820,7 @@ struct e1000_info e1000_82583_info = {
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
 	.pba			= 20,
-	.max_hw_frame_size	= DEFAULT_JUMBO,
+	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
 	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_bm,

