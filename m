From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next PATCH 02/11] ixgbe: Fix SR-IOV VLAN pool configuration
Date: Mon, 02 Nov 2015 17:09:35 -0800
Message-ID: <20151103010935.28233.72294.stgit@localhost.localdomain>
References: <20151103005850.28233.63113.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33545 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbbKCBJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 20:09:37 -0500
Received: by pabfh17 with SMTP id fh17so2109059pab.0
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 17:09:37 -0800 (PST)
In-Reply-To: <20151103005850.28233.63113.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code for checking the PF bit in ixgbe_set_vf_vlan_msg was using the
wrong offset and as a result it was pulling the VLAN off of the PF even if
there were VFs numbered greater than 40 that still had the VLAN enabled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 31de6cf7adb0..61a054ace56d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -887,10 +887,10 @@ static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter *adapter,
 			bits = IXGBE_READ_REG(hw, IXGBE_VLVFB(reg_ndx * 2));
 			bits &= ~(1 << VMDQ_P(0));
 			bits |= IXGBE_READ_REG(hw,
-					       IXGBE_VLVFB(reg_ndx * 2) + 1);
+					       IXGBE_VLVFB(reg_ndx * 2 + 1));
 		} else {
 			bits = IXGBE_READ_REG(hw,
-					      IXGBE_VLVFB(reg_ndx * 2) + 1);
+					      IXGBE_VLVFB(reg_ndx * 2 + 1));
 			bits &= ~(1 << (VMDQ_P(0) - 32));
 			bits |= IXGBE_READ_REG(hw, IXGBE_VLVFB(reg_ndx * 2));
 		}
