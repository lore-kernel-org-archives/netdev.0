From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 6/8] igb: correct typo that was setting vfta mask to 1
Date: Fri, 13 Mar 2009 23:41:55 -0700
Message-ID: <20090314064155.4052.9481.stgit@lost.foo-projects.org>
References: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:57811 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752421AbZCNGmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 02:42:16 -0400
In-Reply-To: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch corrects a typo that was doing a less than comparison instead of
a left shift due to the fact that I didn't get enough <'s in there.

This resolves an issue in which vlans were not functioning correctly.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_mac.c |    2 +-
 drivers/net/igb/igb_main.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index f11592f..f4c315b 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -129,7 +129,7 @@ void igb_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
 s32 igb_vfta_set(struct e1000_hw *hw, u32 vid, bool add)
 {
 	u32 index = (vid >> E1000_VFTA_ENTRY_SHIFT) & E1000_VFTA_ENTRY_MASK;
-	u32 mask = 1 < (vid & E1000_VFTA_ENTRY_BIT_SHIFT_MASK);
+	u32 mask = 1 << (vid & E1000_VFTA_ENTRY_BIT_SHIFT_MASK);
 	u32 vfta = array_rd32(E1000_VFTA, index);
 	s32 ret_val = 0;
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d972f91..3f505ae 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3806,7 +3806,7 @@ static void igb_restore_vf_multicasts(struct igb_adapter *adapter)
 
 	for (i = 0; i < adapter->vfs_allocated_count; i++) {
 		vf_data = &adapter->vf_data[i];
-		for (j = 0; j < vf_data[i].num_vf_mc_hashes; j++)
+		for (j = 0; j < vf_data->num_vf_mc_hashes; j++)
 			igb_mta_set(hw, vf_data->vf_mc_hashes[j]);
 	}
 }

