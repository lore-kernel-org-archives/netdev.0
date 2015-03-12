From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH v2] ixgbe: Remove NETIF_F_HW_VLAN_CTAG_FILTER from
 hw_features
Date: Thu, 12 Mar 2015 08:22:31 -0700
Message-ID: <20150312152055.1319.61781.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: h-shimamoto@ct.jp.nec.com, jeffrey.t.kirsher@intel.com
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbbCLPWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 11:22:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the HW_VLAN_CTAG_FILTER bit is not falsely
advertised as being a feature that can be toggled on ixgbe parts.  The
driver was setting the bit in features and letting it be inherited by
hw_features, however the driver was actually ignoring the value of the bit
and just assuming it was always set.  As a result VLAN filtering was always
enabled which is a requirement for SR-IOV, VMDq, DCB, FCoE, and possibly
other features within the adapters.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---

v2: Updated patch description replacing STAG reference with CTAG

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 21aea7e..08c27ed 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8406,7 +8406,6 @@ skip_sriov:
 			   NETIF_F_IPV6_CSUM |
 			   NETIF_F_HW_VLAN_CTAG_TX |
 			   NETIF_F_HW_VLAN_CTAG_RX |
-			   NETIF_F_HW_VLAN_CTAG_FILTER |
 			   NETIF_F_TSO |
 			   NETIF_F_TSO6 |
 			   NETIF_F_RXHASH |
@@ -8428,6 +8427,7 @@ skip_sriov:
 	}
 
 	netdev->hw_features |= NETIF_F_RXALL;
+	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
