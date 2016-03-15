From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] net: ena: Add a driver for Amazon Elastic Network
 Adapters (ENA)
Date: Tue, 15 Mar 2016 20:19:06 +0800
Message-ID: <201603152057.7Ftefsym%fengguang.wu@intel.com>
References: <1458039006-19956-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Qxx1br4bt0+wmkIi"
Cc: kbuild-all@01.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aliguori@amazon.com, davem@davemloft.net,
	Netanel Belgazal <netanel@annapurnalabs.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	antoine.tenart@free-electrons.com
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1458039006-19956-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Netanel,

[auto build test ERROR on net-next/master]
[also build test ERROR on v4.5 next-20160315]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/Netanel-Belgazal/net-ena-Add-a-driver-for-Amazon-Elastic-Network-Adapters-ENA/20160315-185239
config: um-allmodconfig (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=um 

All error/warnings (new ones prefixed by >>):

   drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_init_rx_cpu_rmap':
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:141:17: error: 'struct net_device' has no member named 'rx_cpu_rmap'
     adapter->netdev->rx_cpu_rmap = alloc_irq_cpu_rmap(adapter->num_queues);
                    ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c:142:22: error: 'struct net_device' has no member named 'rx_cpu_rmap'
     if (!adapter->netdev->rx_cpu_rmap)
                         ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c:147:40: error: 'struct net_device' has no member named 'rx_cpu_rmap'
      rc = irq_cpu_rmap_add(adapter->netdev->rx_cpu_rmap,
                                           ^
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:148:11: error: invalid use of undefined type 'struct msix_entry'
              adapter->msix_entries[irq_idx].vector);
              ^
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:148:32: error: dereferencing pointer to incomplete type 'struct msix_entry'
              adapter->msix_entries[irq_idx].vector);
                                   ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c:150:37: error: 'struct net_device' has no member named 'rx_cpu_rmap'
       free_irq_cpu_rmap(adapter->netdev->rx_cpu_rmap);
                                        ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c:151:19: error: 'struct net_device' has no member named 'rx_cpu_rmap'
       adapter->netdev->rx_cpu_rmap = NULL;
                      ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_rx_skb':
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:816:3: error: implicit declaration of function 'pci_dma_sync_single_for_cpu' [-Werror=implicit-function-declaration]
      pci_dma_sync_single_for_cpu(rx_ring->pdev,
      ^
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:821:3: error: implicit declaration of function 'pci_dma_sync_single_for_device' [-Werror=implicit-function-declaration]
      pci_dma_sync_single_for_device(rx_ring->pdev,
      ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_enable_msix':
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:1179:53: error: invalid application of 'sizeof' to incomplete type 'struct msix_entry'
     adapter->msix_entries = vzalloc(msix_vecs * sizeof(struct msix_entry));
                                                        ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c:1185:3: error: invalid use of undefined type 'struct msix_entry'
      adapter->msix_entries[i].entry = i;
      ^
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:1187:7: error: implicit declaration of function 'pci_enable_msix' [-Werror=implicit-function-declaration]
     rc = pci_enable_msix(adapter->pdev, adapter->msix_entries, msix_vecs);
          ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_setup_mgmnt_intr':
   drivers/net/ethernet/amazon/ena/ena_netdev.c:1221:3: error: invalid use of undefined type 'struct msix_entry'
      adapter->msix_entries[ENA_MGMNT_IRQ_IDX].vector;
      ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_setup_io_intr':
   drivers/net/ethernet/amazon/ena/ena_netdev.c:1242:4: error: invalid use of undefined type 'struct msix_entry'
       adapter->msix_entries[irq_idx].vector;
       ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_disable_msix':
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:1339:3: error: implicit declaration of function 'pci_disable_msix' [-Werror=implicit-function-declaration]
      pci_disable_msix(adapter->pdev);
      ^
   In file included from include/linux/cpumask.h:9:0,
                    from include/linux/cpu_rmap.h:13,
                    from drivers/net/ethernet/amazon/ena/ena_netdev.c:35:
   drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_calc_io_queue_num':
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:2583:42: error: implicit declaration of function 'pci_msix_vec_count' [-Werror=implicit-function-declaration]
     io_queue_num = min_t(int, io_queue_num, pci_msix_vec_count(pdev) - 1);
                                             ^
   include/linux/kernel.h:793:17: note: in definition of macro 'min_t'
     type __min2 = (y);   \
                    ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_set_push_mode':
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:2597:16: error: implicit declaration of function 'pci_select_bars' [-Werror=implicit-function-declaration]
     has_mem_bar = pci_select_bars(pdev, IORESOURCE_MEM) & BIT(ENA_MEM_BAR);
                   ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_release_bars':
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:2735:2: error: implicit declaration of function 'pci_release_selected_regions' [-Werror=implicit-function-declaration]
     pci_release_selected_regions(pdev, release_bars);
     ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_probe':
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:2791:7: error: implicit declaration of function 'pci_enable_device_mem' [-Werror=implicit-function-declaration]
     rc = pci_enable_device_mem(pdev);
          ^
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:2807:7: error: implicit declaration of function 'pci_request_selected_regions' [-Werror=implicit-function-declaration]
     rc = pci_request_selected_regions(pdev, bars, DRV_MODULE_NAME);
          ^
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:2814:21: error: implicit declaration of function 'ioremap' [-Werror=implicit-function-declaration]
     ena_dev->reg_bar = ioremap(pci_resource_start(pdev, ENA_REG_BAR),
                        ^
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:2814:19: warning: assignment makes pointer from integer without a cast [-Wint-conversion]
     ena_dev->reg_bar = ioremap(pci_resource_start(pdev, ENA_REG_BAR),
                      ^
>> drivers/net/ethernet/amazon/ena/ena_netdev.c:2839:22: error: implicit declaration of function 'ioremap_wc' [-Werror=implicit-function-declaration]
      ena_dev->mem_bar = ioremap_wc(pci_resource_start(pdev, ENA_MEM_BAR),
                         ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c:2839:20: warning: assignment makes pointer from integer without a cast [-Wint-conversion]
      ena_dev->mem_bar = ioremap_wc(pci_resource_start(pdev, ENA_MEM_BAR),
                       ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_remove':
   drivers/net/ethernet/amazon/ena/ena_netdev.c:3034:27: error: 'struct net_device' has no member named 'rx_cpu_rmap'
      free_irq_cpu_rmap(netdev->rx_cpu_rmap);
                              ^
   drivers/net/ethernet/amazon/ena/ena_netdev.c:3035:9: error: 'struct net_device' has no member named 'rx_cpu_rmap'
      netdev->rx_cpu_rmap = NULL;
            ^
   cc1: some warnings being treated as errors

vim +141 drivers/net/ethernet/amazon/ena/ena_netdev.c

   135	
   136	static int ena_init_rx_cpu_rmap(struct ena_adapter *adapter)
   137	{
   138		u32 i;
   139		int rc;
   140	
 > 141		adapter->netdev->rx_cpu_rmap = alloc_irq_cpu_rmap(adapter->num_queues);
   142		if (!adapter->netdev->rx_cpu_rmap)
   143			return -ENOMEM;
   144		for (i = 0; i < adapter->num_queues; i++) {
   145			int irq_idx = ENA_IO_IRQ_IDX(i);
   146	
   147			rc = irq_cpu_rmap_add(adapter->netdev->rx_cpu_rmap,
 > 148					      adapter->msix_entries[irq_idx].vector);
   149			if (rc) {
   150				free_irq_cpu_rmap(adapter->netdev->rx_cpu_rmap);
   151				adapter->netdev->rx_cpu_rmap = NULL;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--Qxx1br4bt0+wmkIi
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--Qxx1br4bt0+wmkIi--
