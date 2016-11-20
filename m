From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH net 07/18] net/ena: refactor ena_get_stats64 to be atomic
 context safe
Date: Sun, 20 Nov 2016 20:59:43 +0200
Message-ID: <25b98d9c-9345-ab5a-5d3b-b6a68f3591a0@annapurnalabs.com>
References: <201611201710.x7wUdghv%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, netdev@vger.kernel.org, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201611201710.x7wUdghv%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This warning isn't a real issue since adapter->num_queues can't be zero.
Anyway, I'll use the adapter's syncp in V2 to avoid this warning.

On 11/20/2016 12:09 PM, kbuild test robot wrote:
> Hi Netanel,
>
> [auto build test WARNING on net/master]
>
> url:    https://github.com/0day-ci/linux/commits/Netanel-Belgazal/Update-ENA-driver-to-version-1-1-2/20161120-165649
> config: i386-randconfig-x009-201647 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
>
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
>
> All warnings (new ones prefixed by >>):
>
>    Cyclomatic Complexity 2 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_napi_enable_all
>    Cyclomatic Complexity 1 include/linux/dma-mapping.h:dma_map_single_attrs
>    Cyclomatic Complexity 1 include/linux/dynamic_queue_limits.h:dql_queued
>    Cyclomatic Complexity 3 include/linux/netdevice.h:netdev_tx_sent_queue
>    Cyclomatic Complexity 1 include/linux/netdevice.h:dev_kfree_skb_any
>    Cyclomatic Complexity 1 include/linux/netdevice.h:netdev_tx_reset_queue
>    Cyclomatic Complexity 6 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_free_tx_bufs
>    Cyclomatic Complexity 2 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_free_all_tx_bufs
>    Cyclomatic Complexity 3 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_free_rx_page
>    Cyclomatic Complexity 3 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_free_rx_bufs
>    Cyclomatic Complexity 2 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_free_all_rx_bufs
>    Cyclomatic Complexity 2 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_down
>    Cyclomatic Complexity 4 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_close
>    Cyclomatic Complexity 3 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_update_on_link_change
>    Cyclomatic Complexity 2 include/linux/netdevice.h:napi_schedule_irqoff
>    Cyclomatic Complexity 1 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_intr_msix_io
>    Cyclomatic Complexity 4 include/linux/cpumask.h:cpumask_check
>    Cyclomatic Complexity 1 include/linux/cpumask.h:cpumask_set_cpu
>    Cyclomatic Complexity 2 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_setup_io_intr
>    Cyclomatic Complexity 1 include/linux/interrupt.h:request_irq
>    Cyclomatic Complexity 9 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_request_io_irq
>    Cyclomatic Complexity 5 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_request_mgmnt_irq
>    Cyclomatic Complexity 8 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_setup_tx_resources
>    Cyclomatic Complexity 5 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_setup_all_tx_resources
>    Cyclomatic Complexity 5 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_setup_rx_resources
>    Cyclomatic Complexity 5 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_setup_all_rx_resources
>    Cyclomatic Complexity 5 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_create_io_tx_queue
>    Cyclomatic Complexity 4 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_create_all_io_tx_queues
>    Cyclomatic Complexity 5 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_create_io_rx_queue
>    Cyclomatic Complexity 4 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_create_all_io_rx_queues
>    Cyclomatic Complexity 2 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_init_napi
>    Cyclomatic Complexity 4 drivers/net/ethernet/amazon/ena/ena_eth_com.h:ena_com_update_dev_comp_head
>    Cyclomatic Complexity 2 drivers/net/ethernet/amazon/ena/ena_eth_com.h:ena_com_write_sq_doorbell
>    Cyclomatic Complexity 4 include/linux/netdevice.h:netdev_tx_completed_queue
>    Cyclomatic Complexity 14 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_clean_tx_irq
>    Cyclomatic Complexity 2 include/linux/netdevice.h:netif_tx_unlock
>    Cyclomatic Complexity 1 include/linux/skbuff.h:__netdev_alloc_skb_ip_align
>    Cyclomatic Complexity 1 include/linux/skbuff.h:netdev_alloc_skb_ip_align
>    Cyclomatic Complexity 16 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_rx_skb
>    Cyclomatic Complexity 1 include/linux/gfp.h:__alloc_pages
>    Cyclomatic Complexity 1 include/linux/gfp.h:__alloc_pages_node
>    Cyclomatic Complexity 2 include/linux/gfp.h:alloc_pages_node
>    Cyclomatic Complexity 6 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_alloc_rx_page
>    Cyclomatic Complexity 8 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_refill_rx_bufs
>    Cyclomatic Complexity 11 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_clean_rx_irq
>    Cyclomatic Complexity 4 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_refill_all_rx_bufs
>    Cyclomatic Complexity 5 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_update_ring_numa_node
>    Cyclomatic Complexity 8 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_change_mtu
>    Cyclomatic Complexity 2 include/linux/netdevice.h:napi_schedule
>    Cyclomatic Complexity 1 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_device_io_resume
>    Cyclomatic Complexity 1 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_device_io_suspend
>    Cyclomatic Complexity 2 include/linux/seqlock.h:seqcount_lockdep_reader_access
>    Cyclomatic Complexity 1 include/linux/seqlock.h:read_seqcount_begin
>    Cyclomatic Complexity 1 include/linux/u64_stats_sync.h:__u64_stats_fetch_begin
>    Cyclomatic Complexity 1 include/linux/u64_stats_sync.h:u64_stats_fetch_begin_irq
>    Cyclomatic Complexity 6 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_get_stats64
>    Cyclomatic Complexity 6 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_notification
>    Cyclomatic Complexity 2 include/linux/skbuff.h:__skb_linearize
>    Cyclomatic Complexity 2 include/linux/skbuff.h:skb_linearize
>    Cyclomatic Complexity 5 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_check_and_linearize_skb
>    Cyclomatic Complexity 3 include/linux/skbuff.h:sw_tx_timestamp
>    Cyclomatic Complexity 1 include/linux/skbuff.h:skb_tx_timestamp
>    Cyclomatic Complexity 22 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_start_xmit
>    Cyclomatic Complexity 1 arch/x86/include/asm/io.h:ioremap
>    Cyclomatic Complexity 4 include/linux/dma-mapping.h:dma_set_mask
>    Cyclomatic Complexity 1 include/linux/pci-dma-compat.h:pci_set_dma_mask
>    Cyclomatic Complexity 2 include/linux/dma-mapping.h:dma_set_coherent_mask
>    Cyclomatic Complexity 1 include/linux/pci-dma-compat.h:pci_set_consistent_dma_mask
>    Cyclomatic Complexity 4 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_config_host_info
>    Cyclomatic Complexity 12 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_device_init
>    Cyclomatic Complexity 4 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_calc_io_queue_num
>    Cyclomatic Complexity 69 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_calc_queue_size
>    Cyclomatic Complexity 1 include/linux/etherdevice.h:eth_random_addr
>    Cyclomatic Complexity 1 include/linux/etherdevice.h:eth_hw_addr_random
>    Cyclomatic Complexity 2 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_set_conf_feat_params
>    Cyclomatic Complexity 2 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_init_io_rings
>    Cyclomatic Complexity 1 include/linux/cpu_rmap.h:alloc_irq_cpu_rmap
>    Cyclomatic Complexity 4 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_init_rx_cpu_rmap
>    Cyclomatic Complexity 14 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_enable_msix
>    Cyclomatic Complexity 2 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_intr_msix_mgmnt
>    Cyclomatic Complexity 1 include/linux/cpumask.h:cpumask_first
>    Cyclomatic Complexity 1 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_setup_mgmnt_intr
>    Cyclomatic Complexity 3 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_enable_msix_and_set_admin_interrupts
>    Cyclomatic Complexity 6 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_rss_init_default
>    Cyclomatic Complexity 7 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_rss_configure
>    Cyclomatic Complexity 3 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_up_complete
>    Cyclomatic Complexity 9 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_up
>    Cyclomatic Complexity 7 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_fw_reset_device
>    Cyclomatic Complexity 6 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_open
>    Cyclomatic Complexity 8 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_config_debug_area
>    Cyclomatic Complexity 21 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_probe
>    Cyclomatic Complexity 2 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_init
>    Cyclomatic Complexity 1 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_adjust_intr_moderation
>    Cyclomatic Complexity 4 drivers/net/ethernet/amazon/ena/ena_netdev.c:ena_io_poll
>    In file included from include/linux/linkage.h:4:0,
>                     from include/linux/kernel.h:6,
>                     from include/linux/cpumask.h:9,
>                     from include/linux/cpu_rmap.h:13,
>                     from drivers/net/ethernet/amazon/ena/ena_netdev.c:36:
>    drivers/net/ethernet/amazon/ena/ena_netdev.c: In function 'ena_get_stats64':
>>> include/linux/compiler.h:231:26: warning: 'rx_ring' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      case 4: *(__u32 *)res = *(volatile __u32 *)p; break;  \
>                              ^
>    drivers/net/ethernet/amazon/ena/ena_netdev.c:2188:19: note: 'rx_ring' was declared here
>      struct ena_ring *rx_ring, *tx_ring;
>                       ^~~~~~~
>
> vim +/rx_ring +231 include/linux/compiler.h
>
> fe8c8a12 Cesar Eduardo Barros  2013-11-25  215  #ifndef OPTIMIZER_HIDE_VAR
> fe8c8a12 Cesar Eduardo Barros  2013-11-25  216  #define OPTIMIZER_HIDE_VAR(var) barrier()
> fe8c8a12 Cesar Eduardo Barros  2013-11-25  217  #endif
> fe8c8a12 Cesar Eduardo Barros  2013-11-25  218  
> 6f33d587 Rusty Russell         2012-11-22  219  /* Not-quite-unique ID. */
> 6f33d587 Rusty Russell         2012-11-22  220  #ifndef __UNIQUE_ID
> 6f33d587 Rusty Russell         2012-11-22  221  # define __UNIQUE_ID(prefix) __PASTE(__PASTE(__UNIQUE_ID_, prefix), __LINE__)
> 6f33d587 Rusty Russell         2012-11-22  222  #endif
> 6f33d587 Rusty Russell         2012-11-22  223  
> 230fa253 Christian Borntraeger 2014-11-25  224  #include <uapi/linux/types.h>
> 230fa253 Christian Borntraeger 2014-11-25  225  
> d976441f Andrey Ryabinin       2015-10-19  226  #define __READ_ONCE_SIZE						\
> d976441f Andrey Ryabinin       2015-10-19  227  ({									\
> d976441f Andrey Ryabinin       2015-10-19  228  	switch (size) {							\
> d976441f Andrey Ryabinin       2015-10-19  229  	case 1: *(__u8 *)res = *(volatile __u8 *)p; break;		\
> d976441f Andrey Ryabinin       2015-10-19  230  	case 2: *(__u16 *)res = *(volatile __u16 *)p; break;		\
> d976441f Andrey Ryabinin       2015-10-19 @231  	case 4: *(__u32 *)res = *(volatile __u32 *)p; break;		\
> d976441f Andrey Ryabinin       2015-10-19  232  	case 8: *(__u64 *)res = *(volatile __u64 *)p; break;		\
> d976441f Andrey Ryabinin       2015-10-19  233  	default:							\
> d976441f Andrey Ryabinin       2015-10-19  234  		barrier();						\
> d976441f Andrey Ryabinin       2015-10-19  235  		__builtin_memcpy((void *)res, (const void *)p, size);	\
> d976441f Andrey Ryabinin       2015-10-19  236  		barrier();						\
> d976441f Andrey Ryabinin       2015-10-19  237  	}								\
> d976441f Andrey Ryabinin       2015-10-19  238  })
> d976441f Andrey Ryabinin       2015-10-19  239  
>
> :::::: The code at line 231 was first introduced by commit
> :::::: d976441f44bc5d48635d081d277aa76556ffbf8b compiler, atomics, kasan: Provide READ_ONCE_NOCHECK()
>
> :::::: TO: Andrey Ryabinin <aryabinin@virtuozzo.com>
> :::::: CC: Ingo Molnar <mingo@kernel.org>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
