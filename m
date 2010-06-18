From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/4] e1000e: packet split should not be used with
	early receive
Date: Thu, 17 Jun 2010 21:59:27 -0700
Message-ID: <20100618045925.6728.43858.stgit@localhost.localdomain>
References: <20100618045804.6728.37945.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:38006
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752399Ab0FRE7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 00:59:46 -0400
In-Reply-To: <20100618045804.6728.37945.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Originally it was thought there were issues with ICHx/PCH parts with packet
split when jumbo frames were enabled but in fact it is really only when
early-receive is enabled (via ERT register) on these parts.  Use packet
split with jumbos but only when early-receive is not enabled.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index aa14976..71592ed 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2772,7 +2772,7 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	 * per packet.
 	 */
 	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
-	if (!(adapter->flags & FLAG_IS_ICH) && (pages <= 3) &&
+	if (!(adapter->flags & FLAG_HAS_ERT) && (pages <= 3) &&
 	    (PAGE_SIZE <= 16384) && (rctl & E1000_RCTL_LPE))
 		adapter->rx_ps_pages = pages;
 	else

