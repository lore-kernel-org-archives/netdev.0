From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ixgbe: using is_zero_ether_addr() to simplify the code
Date: Sun, 26 Aug 2012 08:53:41 +0800
Message-ID: <CAPgLHd_4FkMaEuBBbjSEFnQzP8=x0EeT=6Z1LNiHE7ycOvNziQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:52125 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886Ab2HZAxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 20:53:42 -0400
Received: by qcro28 with SMTP id o28so1925762qcr.19
        for <netdev@vger.kernel.org>; Sat, 25 Aug 2012 17:53:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using is_zero_ether_addr() to simplify the code.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 90e41db..dc9f28f0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -1777,8 +1777,7 @@ s32 ixgbe_validate_mac_addr(u8 *mac_addr)
 	else if (IXGBE_IS_BROADCAST(mac_addr))
 		status = IXGBE_ERR_INVALID_MAC_ADDR;
 	/* Reject the zero address */
-	else if (mac_addr[0] == 0 && mac_addr[1] == 0 && mac_addr[2] == 0 &&
-	         mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0)
+	else if (is_zero_ether_addr(mac_addr))
 		status = IXGBE_ERR_INVALID_MAC_ADDR;
 
 	return status;
