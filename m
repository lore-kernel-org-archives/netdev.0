From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/5] ixgbe: fix masking of bits read from IXGBE_VXLANCTRL register
Date: Mon,  9 Oct 2017 08:12:48 -0700
Message-ID: <20171009151251.53939-3-jeffrey.t.kirsher@intel.com>
References: <20171009151251.53939-1-jeffrey.t.kirsher@intel.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:48022 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754209AbdJIPNP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 11:13:15 -0400
In-Reply-To: <20171009151251.53939-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>

In ixgbe_clear_udp_tunnel_port(), we read the IXGBE_VXLANCTRL register
and then try to mask some bits out of the value, using the logical
instead of bitwise and operator.

Fixes: a21d0822ff69 ("ixgbe: add support for geneve Rx offload")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 822cdb4f2c25..4d76afd13868 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4881,7 +4881,7 @@ static void ixgbe_clear_udp_tunnel_port(struct ixgbe_adapter *adapter, u32 mask)
 				IXGBE_FLAG_GENEVE_OFFLOAD_CAPABLE)))
 		return;
 
-	vxlanctrl = IXGBE_READ_REG(hw, IXGBE_VXLANCTRL) && ~mask;
+	vxlanctrl = IXGBE_READ_REG(hw, IXGBE_VXLANCTRL) & ~mask;
 	IXGBE_WRITE_REG(hw, IXGBE_VXLANCTRL, vxlanctrl);
 
 	if (mask & IXGBE_VXLANCTRL_VXLAN_UDPPORT_MASK)
-- 
2.14.2
