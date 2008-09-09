From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 07/24] ixgbe: limit small mtu to minimum for ipv4
	support
Date: Mon, 08 Sep 2008 21:47:51 -0700
Message-ID: <20080909044751.18904.48657.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:14735 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754836AbYIIEry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:47:54 -0400
Received: by wx-out-0506.google.com with SMTP id h27so422246wxd.4
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:47:53 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index cfaa3ca..2c8895e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2839,8 +2839,8 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
-	if ((max_frame < (ETH_ZLEN + ETH_FCS_LEN)) ||
-	    (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
+	/* MTU < 68 is an error and causes problems on some kernels */
+	if ((new_mtu < 68) || (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
 		return -EINVAL;
 
 	DPRINTK(PROBE, INFO, "changing MTU from %d to %d\n",

