From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 15/18] igb: remove unused vmolr value
Date: Wed, 17 Feb 2010 03:05:15 -0800
Message-ID: <20100217110514.17723.55708.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:44349 "EHLO
	qmta02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754862Ab0BQLFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:05:33 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

In an earlier version of igb_write_mc_addr_list() the vmolr register
was modified. This register is no longer accessed, although the variable
still exists. This patch removes it from the function.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ff392e9..a9f4e02 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2883,7 +2883,6 @@ static int igb_write_mc_addr_list(struct net_device *netdev)
 	struct e1000_hw *hw = &adapter->hw;
 	struct dev_mc_list *mc_ptr = netdev->mc_list;
 	u8  *mta_list;
-	u32 vmolr = 0;
 	int i;
 
 	if (netdev_mc_empty(netdev)) {
@@ -2897,9 +2896,6 @@ static int igb_write_mc_addr_list(struct net_device *netdev)
 	if (!mta_list)
 		return -ENOMEM;
 
-	/* set vmolr receive overflow multicast bit */
-	vmolr |= E1000_VMOLR_ROMPE;
-
 	/* The shared function expects a packed array of only addresses. */
 	mc_ptr = netdev->mc_list;
 

