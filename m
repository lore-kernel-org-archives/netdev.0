From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH 3/3] net: drivers: set IFF_OFFLOADED_FDB priv flag on
	ixgbe and igb
Date: Tue, 28 Feb 2012 23:17:25 -0800
Message-ID: <20120229071725.10937.97402.stgit@jf-dev1-dcblab>
References: <20120229070418.10937.8692.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, bhutchings@solarflare.com, roprabhu@cisco.com,
	mst@redhat.com, netdev@vger.kernel.org, gregory.v.rose@intel.com,
	davem@davemloft.net
To: jhs@mojatatu.com, shemminger@vyatta.com, kernel@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61561 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030751Ab2B2H31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 02:29:27 -0500
In-Reply-To: <20120229070418.10937.8692.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This sets the IFF_OFFLOADED_FDB in the priv flags when SR-IOV is
enabled on ixgbe and igb devices.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ethernet/intel/igb/igb_main.c     |    2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 +++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index fda8247..1b4b8de 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2272,6 +2272,8 @@ static void __devinit igb_probe_vfs(struct igb_adapter * adapter)
 	for (i = 0; i < adapter->vfs_allocated_count; i++)
 		igb_vf_configure(adapter, i);
 
+	adapter->netdev->priv_flags |= IFF_OFFLOADED_FDB;
+
 	/* DMA Coalescing is not supported in IOV mode. */
 	adapter->flags &= ~IGB_FLAG_DMAC;
 	goto out;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4e55860..ff5599b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7753,9 +7753,11 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		netdev->priv_flags |= IFF_OFFLOADED_FDB;
 		adapter->flags &= ~(IXGBE_FLAG_RSS_ENABLED |
 				    IXGBE_FLAG_DCB_ENABLED);
+	}
 
 #ifdef CONFIG_IXGBE_DCB
 	netdev->dcbnl_ops = &dcbnl_ops;
