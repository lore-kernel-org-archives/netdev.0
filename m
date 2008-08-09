From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/7] e1000e: Return 1 instead of a non-zero value for link up
	indication
Date: Fri, 08 Aug 2008 18:35:44 -0700
Message-ID: <20080809013544.23913.47157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52971 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbYHIBfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 21:35:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

A number of users have mentioned they have tools that rely on a link-up
indication having a return value of 1 rather than a non-zero value.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index cf9679f..e21c9e0 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -177,7 +177,7 @@ static u32 e1000_get_link(struct net_device *netdev)
 	u32 status;
 	
 	status = er32(STATUS);
-	return (status & E1000_STATUS_LU);
+	return (status & E1000_STATUS_LU) ? 1 : 0;
 }
 
 static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)

