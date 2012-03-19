From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v0 5/5] ixgbe: allow RAR table to be updated in
	promisc mode
Date: Sun, 18 Mar 2012 23:52:15 -0700
Message-ID: <20120319065214.10959.12406.stgit@jf-dev1-dcblab>
References: <20120319064719.10959.93361.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	gregory.v.rose@intel.com, kvm@vger.kernel.org, sri@us.ibm.com,
	chealy@imsco-us.com
To: jhs@mojatatu.com, shemminger@vyatta.com, bhutchings@solarflare.com,
	roprabhu@cisco.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120319064719.10959.93361.stgit@jf-dev1-dcblab>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows RAR table updates while in promiscuous. With
SR-IOV enabled it is valuable to allow the RAR table to
be updated even when in promisc mode to configure forwarding

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 32adb4f..d1925b5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3400,16 +3400,17 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		}
 		ixgbe_vlan_filter_enable(adapter);
 		hw->addr_ctrl.user_set_promisc = false;
-		/*
-		 * Write addresses to available RAR registers, if there is not
-		 * sufficient space to store all the addresses then enable
-		 * unicast promiscuous mode
-		 */
-		count = ixgbe_write_uc_addr_list(netdev);
-		if (count < 0) {
-			fctrl |= IXGBE_FCTRL_UPE;
-			vmolr |= IXGBE_VMOLR_ROPE;
-		}
+	}
+
+	/*
+	 * Write addresses to available RAR registers, if there is not
+	 * sufficient space to store all the addresses then enable
+	 * unicast promiscuous mode
+	 */
+	count = ixgbe_write_uc_addr_list(netdev);
+	if (count < 0) {
+		fctrl |= IXGBE_FCTRL_UPE;
+		vmolr |= IXGBE_VMOLR_ROPE;
 	}
 
 	if (adapter->num_vfs) {

