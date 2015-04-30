From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 0/3] Stop using dev_kfree_skb_any in NAPI Tx clean-up
Date: Thu, 30 Apr 2015 13:58:12 -0700
Message-ID: <20150430205423.1512.13487.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, Dept-HSGLinuxNICDev@qlogic.com,
	sony.chacko@qlogic.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47578 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809AbbD3U6W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 16:58:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the call to dev_kfree_skb_any in several NAPI based Tx
clean-up paths with dev_kfree_skb.  Where I made the replacement the
function appeared to always be in softirq context so we can avoid the
unnecessary time spent determining if we are in a hardirq context or not.

---

Alexander Duyck (3):
      igb, ixgbe(vf), i40e(vf), fm10k: Use dev_kfree_skb in Tx cleanup path
      r8169: Use dev_kfree_skb in Tx cleanup path
      bnx2: Use dev_kfree_skb in Tx cleanup path


 drivers/net/ethernet/broadcom/bnx2.c              |    2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |    2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 drivers/net/ethernet/realtek/r8169.c              |    2 +-
 8 files changed, 8 insertions(+), 8 deletions(-)

--
