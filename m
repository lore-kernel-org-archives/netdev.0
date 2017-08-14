From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next 2/3] Add LAN743X to Kconfig and Makefile (fwd)
Date: Mon, 14 Aug 2017 12:20:07 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1708141217280.3368@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com, kbuild-all@01.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:38711
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752746AbdHNKU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 06:20:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't think netdev_priv can return NULL, so lines 6641 to 6646 could
just be dropped.

julia

---------- Forwarded message ----------
Date: Mon, 14 Aug 2017 18:14:12 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next 2/3] Add LAN743X to Kconfig and Makefile

CC: kbuild-all@01.org
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264406F6049@CHN-SV-EXMX02.mchp-main.com>
TO: Bryan.Whitehead@microchip.com
CC: netdev@vger.kernel.org, davem@davemloft.net
CC: UNGLinuxDriver@microchip.com

Hi Bryan,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Bryan-Whitehead-microchip-com/Add-LAN743X-driver/20170814-141247
:::::: branch date: 4 hours ago
:::::: commit date: 4 hours ago

>> drivers/net/ethernet/microchip/lan743x.c:6642:39-45: ERROR: adapter is NULL but dereferenced.

# https://github.com/0day-ci/linux/commit/dabee19fb26fee5184b2b304b12080be0f78a3f2
git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout dabee19fb26fee5184b2b304b12080be0f78a3f2
vim +6642 drivers/net/ethernet/microchip/lan743x.c

a33f5600 Bryan Whitehead 2017-08-11  6609
a33f5600 Bryan Whitehead 2017-08-11  6610  /* lan743x_pcidev_probe - Device Initialization Routine
a33f5600 Bryan Whitehead 2017-08-11  6611   * @pdev: PCI device information struct
a33f5600 Bryan Whitehead 2017-08-11  6612   * @id: entry in lan743x_pci_tbl
a33f5600 Bryan Whitehead 2017-08-11  6613   *
a33f5600 Bryan Whitehead 2017-08-11  6614   * Returns 0 on success, negative on failure
a33f5600 Bryan Whitehead 2017-08-11  6615   *
a33f5600 Bryan Whitehead 2017-08-11  6616   * initializes an adapter identified by a pci_dev structure.
a33f5600 Bryan Whitehead 2017-08-11  6617   * The OS initialization, configuring of the adapter private structure,
a33f5600 Bryan Whitehead 2017-08-11  6618   * and a hardware reset occur.
a33f5600 Bryan Whitehead 2017-08-11  6619   **/
a33f5600 Bryan Whitehead 2017-08-11  6620  static int lan743x_pcidev_probe(struct pci_dev *pdev,
a33f5600 Bryan Whitehead 2017-08-11  6621  				const struct pci_device_id *id)
a33f5600 Bryan Whitehead 2017-08-11  6622  {
a33f5600 Bryan Whitehead 2017-08-11  6623  	struct net_device *netdev = NULL;
a33f5600 Bryan Whitehead 2017-08-11  6624  	struct lan743x_adapter *adapter = NULL;
a33f5600 Bryan Whitehead 2017-08-11  6625  	int ret = -ENODEV;
a33f5600 Bryan Whitehead 2017-08-11  6626
a33f5600 Bryan Whitehead 2017-08-11  6627  	NETIF_ASSERT(adapter, probe, adapter->netdev, pdev);
a33f5600 Bryan Whitehead 2017-08-11  6628
a33f5600 Bryan Whitehead 2017-08-11  6629  	netdev = alloc_etherdev(sizeof(struct lan743x_adapter));
a33f5600 Bryan Whitehead 2017-08-11  6630  	if (!netdev) {
a33f5600 Bryan Whitehead 2017-08-11  6631  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6632  			    "alloc_etherdev returned NULL");
a33f5600 Bryan Whitehead 2017-08-11  6633  		ret = -ENOMEM;
a33f5600 Bryan Whitehead 2017-08-11  6634  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6635  	}
a33f5600 Bryan Whitehead 2017-08-11  6636
a33f5600 Bryan Whitehead 2017-08-11  6637  	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
a33f5600 Bryan Whitehead 2017-08-11  6638  	SET_NETDEV_DEV(netdev, &pdev->dev);
a33f5600 Bryan Whitehead 2017-08-11  6639  	pci_set_drvdata(pdev, netdev);
a33f5600 Bryan Whitehead 2017-08-11  6640  	adapter = netdev_priv(netdev);
a33f5600 Bryan Whitehead 2017-08-11  6641  	if (!adapter) {
a33f5600 Bryan Whitehead 2017-08-11 @6642  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6643  			    "netdev_priv returned NULL");
a33f5600 Bryan Whitehead 2017-08-11  6644  		ret = -ENOMEM;
a33f5600 Bryan Whitehead 2017-08-11  6645  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6646  	}
a33f5600 Bryan Whitehead 2017-08-11  6647  	memset(adapter, 0, sizeof(struct lan743x_adapter));
a33f5600 Bryan Whitehead 2017-08-11  6648  	adapter->netdev = netdev;
a33f5600 Bryan Whitehead 2017-08-11  6649  	adapter->init_flags = 0;
a33f5600 Bryan Whitehead 2017-08-11  6650  	adapter->open_flags = 0;
a33f5600 Bryan Whitehead 2017-08-11  6651  	adapter->msg_enable = msg_enable;
a33f5600 Bryan Whitehead 2017-08-11  6652  	netdev->max_mtu = LAN743X_MAX_FRAME_SIZE;
a33f5600 Bryan Whitehead 2017-08-11  6653
a33f5600 Bryan Whitehead 2017-08-11  6654  	ret = lan743x_pci_init(adapter, pdev);
a33f5600 Bryan Whitehead 2017-08-11  6655  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6656  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6657  			    "lan743x_pci_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6658  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6659  	}
a33f5600 Bryan Whitehead 2017-08-11  6660  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_PCI;
a33f5600 Bryan Whitehead 2017-08-11  6661
a33f5600 Bryan Whitehead 2017-08-11  6662  	ret = lan743x_csr_init(adapter);
a33f5600 Bryan Whitehead 2017-08-11  6663  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6664  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6665  			    "lan743x_csr_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6666  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6667  	}
a33f5600 Bryan Whitehead 2017-08-11  6668  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_CSR;
a33f5600 Bryan Whitehead 2017-08-11  6669
a33f5600 Bryan Whitehead 2017-08-11  6670  	ret = lan743x_intr_init(adapter);
a33f5600 Bryan Whitehead 2017-08-11  6671  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6672  		NETIF_ERROR(adapter, drv, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6673  			    "lan743x_intr_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6674  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6675  	}
a33f5600 Bryan Whitehead 2017-08-11  6676  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_INTR;
a33f5600 Bryan Whitehead 2017-08-11  6677
a33f5600 Bryan Whitehead 2017-08-11  6678  	ret = lan743x_dp_init(adapter);
a33f5600 Bryan Whitehead 2017-08-11  6679  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6680  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6681  			    "lan743x_dp_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6682  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6683  	}
a33f5600 Bryan Whitehead 2017-08-11  6684  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_DP;
a33f5600 Bryan Whitehead 2017-08-11  6685
a33f5600 Bryan Whitehead 2017-08-11  6686  	ret = lan743x_gpio_init(adapter);
a33f5600 Bryan Whitehead 2017-08-11  6687  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6688  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6689  			    "lan743x_gpio_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6690  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6691  	}
a33f5600 Bryan Whitehead 2017-08-11  6692  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_GPIO;
a33f5600 Bryan Whitehead 2017-08-11  6693
a33f5600 Bryan Whitehead 2017-08-11  6694  	ret = lan743x_mac_init(adapter);
a33f5600 Bryan Whitehead 2017-08-11  6695  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6696  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6697  			    "lan743x_mac_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6698  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6699  	}
a33f5600 Bryan Whitehead 2017-08-11  6700  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_MAC;
a33f5600 Bryan Whitehead 2017-08-11  6701
a33f5600 Bryan Whitehead 2017-08-11  6702  	ret = lan743x_phy_init(adapter);
a33f5600 Bryan Whitehead 2017-08-11  6703  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6704  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6705  			    "lan743x_phy_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6706  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6707  	}
a33f5600 Bryan Whitehead 2017-08-11  6708  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_PHY;
a33f5600 Bryan Whitehead 2017-08-11  6709
a33f5600 Bryan Whitehead 2017-08-11  6710  	ret = lan743x_ptp_init(adapter);
a33f5600 Bryan Whitehead 2017-08-11  6711  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6712  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6713  			    "lan743x_ptp_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6714  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6715  	}
a33f5600 Bryan Whitehead 2017-08-11  6716  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_PTP;
a33f5600 Bryan Whitehead 2017-08-11  6717
a33f5600 Bryan Whitehead 2017-08-11  6718  	ret = lan743x_rfe_init(adapter);
a33f5600 Bryan Whitehead 2017-08-11  6719  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6720  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6721  			    "lan743x_rfe_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6722  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6723  	}
a33f5600 Bryan Whitehead 2017-08-11  6724  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_RFE;
a33f5600 Bryan Whitehead 2017-08-11  6725
a33f5600 Bryan Whitehead 2017-08-11  6726  	ret = lan743x_fct_init(adapter);
a33f5600 Bryan Whitehead 2017-08-11  6727  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6728  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6729  			    "lan743x_fct_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6730  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6731  	}
a33f5600 Bryan Whitehead 2017-08-11  6732  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_FCT;
a33f5600 Bryan Whitehead 2017-08-11  6733
a33f5600 Bryan Whitehead 2017-08-11  6734  	ret = lan743x_dmac_init(adapter);
a33f5600 Bryan Whitehead 2017-08-11  6735  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6736  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6737  			    "lan743x_dmac_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6738  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6739  	}
a33f5600 Bryan Whitehead 2017-08-11  6740  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_DMAC;
a33f5600 Bryan Whitehead 2017-08-11  6741
a33f5600 Bryan Whitehead 2017-08-11  6742  	ret = lan743x_rx_init(&adapter->rx[0], adapter, 0);
a33f5600 Bryan Whitehead 2017-08-11  6743  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6744  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6745  			    "lan743x_rx_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6746  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6747  	}
a33f5600 Bryan Whitehead 2017-08-11  6748  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_RX(0);
a33f5600 Bryan Whitehead 2017-08-11  6749
a33f5600 Bryan Whitehead 2017-08-11  6750  	ret = lan743x_tx_init(&adapter->tx[0], adapter, 0);
a33f5600 Bryan Whitehead 2017-08-11  6751  	if (ret) {
a33f5600 Bryan Whitehead 2017-08-11  6752  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6753  			    "lan743x_tx_init failed, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6754  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6755  	}
a33f5600 Bryan Whitehead 2017-08-11  6756  	adapter->init_flags |= LAN743X_COMPONENT_FLAG_TX(0);
a33f5600 Bryan Whitehead 2017-08-11  6757
a33f5600 Bryan Whitehead 2017-08-11  6758  	netdev->netdev_ops = &lan743x_netdev_ops;
a33f5600 Bryan Whitehead 2017-08-11  6759  	netdev->ethtool_ops = &lan743x_ethtool_ops;
a33f5600 Bryan Whitehead 2017-08-11  6760  	netdev->features = NETIF_F_SG | NETIF_F_TSO | NETIF_F_HW_CSUM;
a33f5600 Bryan Whitehead 2017-08-11  6761  	netdev->hw_features = netdev->features;
a33f5600 Bryan Whitehead 2017-08-11  6762
a33f5600 Bryan Whitehead 2017-08-11  6763  	strncpy(netdev->name, "eth%d", sizeof(netdev->name));
a33f5600 Bryan Whitehead 2017-08-11  6764  	ret = register_netdev(netdev);
a33f5600 Bryan Whitehead 2017-08-11  6765  	if (ret < 0) {
a33f5600 Bryan Whitehead 2017-08-11  6766  		NETIF_ERROR(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6767  			    "failed to register net device, ret = %d", ret);
a33f5600 Bryan Whitehead 2017-08-11  6768  		goto clean_up;
a33f5600 Bryan Whitehead 2017-08-11  6769  	}
a33f5600 Bryan Whitehead 2017-08-11  6770  	adapter->init_flags |= LAN743X_INIT_FLAG_NETDEV_REGISTERED;
a33f5600 Bryan Whitehead 2017-08-11  6771
a33f5600 Bryan Whitehead 2017-08-11  6772  	NETIF_INFO(adapter, probe, adapter->netdev, "Probe succeeded");
a33f5600 Bryan Whitehead 2017-08-11  6773  	ret = 0;
a33f5600 Bryan Whitehead 2017-08-11  6774
a33f5600 Bryan Whitehead 2017-08-11  6775  clean_up:
a33f5600 Bryan Whitehead 2017-08-11  6776  	if (ret && adapter) {
a33f5600 Bryan Whitehead 2017-08-11  6777  		NETIF_WARNING(adapter, probe, adapter->netdev,
a33f5600 Bryan Whitehead 2017-08-11  6778  			      "Incomplete initialization, performing clean up");
a33f5600 Bryan Whitehead 2017-08-11  6779  		lan743x_device_cleanup(adapter);
a33f5600 Bryan Whitehead 2017-08-11  6780  	}
a33f5600 Bryan Whitehead 2017-08-11  6781  	return ret;
a33f5600 Bryan Whitehead 2017-08-11  6782  }
a33f5600 Bryan Whitehead 2017-08-11  6783

:::::: The code at line 6642 was first introduced by commit
:::::: a33f5600a21257dc396a7278c7c5ff74ac2f7844 Add LAN743X driver

:::::: TO: Bryan Whitehead <Bryan.Whitehead@microchip.com>
:::::: CC: 0day robot <fengguang.wu@intel.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
