From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next:  build warnings after merge of the net-next tree
Date: Tue, 22 Nov 2016 12:22:16 +1100
Message-ID: <20161122122216.575b1793@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) produced these warnings:

drivers/net/ethernet/marvell/mvneta_bm.c: In function 'mvneta_bm_construct':
drivers/net/ethernet/marvell/mvneta_bm.c:103:16: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
  *(u32 *)buf = (u32)buf;
                ^
In file included from include/linux/clk.h:16:0,
                 from drivers/net/ethernet/marvell/mvneta_bm.c:13:
drivers/net/ethernet/marvell/mvneta_bm.c: In function 'mvneta_bm_pool_create':
drivers/net/ethernet/marvell/mvneta_bm.c:128:18: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
  if (!IS_ALIGNED((u32)bm_pool->virt_addr, MVNETA_BM_POOL_PTR_ALIGN)) {
                  ^
include/linux/kernel.h:51:30: note: in definition of macro 'IS_ALIGNED'
 #define IS_ALIGNED(x, a)  (((x) & ((typeof(x))(a) - 1)) == 0)
                              ^
drivers/net/ethernet/marvell/mvneta_bm.c:128:18: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
  if (!IS_ALIGNED((u32)bm_pool->virt_addr, MVNETA_BM_POOL_PTR_ALIGN)) {
                  ^
include/linux/kernel.h:51:44: note: in definition of macro 'IS_ALIGNED'
 #define IS_ALIGNED(x, a)  (((x) & ((typeof(x))(a) - 1)) == 0)
                                            ^
drivers/net/ethernet/marvell/mvneta.c: In function 'mvneta_rx_refill':
drivers/net/ethernet/marvell/mvneta.c:1802:42: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
  mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)data);
                                          ^
drivers/net/ethernet/marvell/mvneta.c: In function 'mvneta_rxq_drop_pkts':
drivers/net/ethernet/marvell/mvneta.c:1864:16: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
   void *data = (void *)rx_desc->buf_cookie;
                ^
drivers/net/ethernet/marvell/mvneta.c: In function 'mvneta_rx_swbm':
drivers/net/ethernet/marvell/mvneta.c:1902:10: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
   data = (unsigned char *)rx_desc->buf_cookie;
          ^
drivers/net/ethernet/marvell/mvneta.c: In function 'mvneta_rx_hwbm':
drivers/net/ethernet/marvell/mvneta.c:2023:10: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
   data = (unsigned char *)rx_desc->buf_cookie;
          ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_prs_mac_promisc_set':
drivers/net/ethernet/marvell/mvpp2.c:524:33: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_L2_UCAST   ~(BIT(9) | BIT(10))
                                 ^
drivers/net/ethernet/marvell/mvpp2.c:1459:33: note: in expansion of macro 'MVPP2_PRS_RI_L2_UCAST'
   mvpp2_prs_sram_ri_update(&pe, MVPP2_PRS_RI_L2_UCAST,
                                 ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_prs_dsa_tag_set':
drivers/net/ethernet/marvell/mvpp2.c:517:34: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_VLAN_NONE   ~(BIT(2) | BIT(3))
                                  ^
drivers/net/ethernet/marvell/mvpp2.c:1572:34: note: in expansion of macro 'MVPP2_PRS_RI_VLAN_NONE'
    mvpp2_prs_sram_ri_update(&pe, MVPP2_PRS_RI_VLAN_NONE,
                                  ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_prs_dsa_tag_ethertype_set':
drivers/net/ethernet/marvell/mvpp2.c:517:34: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_VLAN_NONE   ~(BIT(2) | BIT(3))
                                  ^
drivers/net/ethernet/marvell/mvpp2.c:1642:34: note: in expansion of macro 'MVPP2_PRS_RI_VLAN_NONE'
    mvpp2_prs_sram_ri_update(&pe, MVPP2_PRS_RI_VLAN_NONE,
                                  ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_prs_etype_init':
drivers/net/ethernet/marvell/mvpp2.c:529:30: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_L3_UN   ~(BIT(12) | BIT(13) | BIT(14))
                              ^
drivers/net/ethernet/marvell/mvpp2.c:2477:32: note: in expansion of macro 'MVPP2_PRS_RI_L3_UN'
  mvpp2_prs_sram_ri_update(&pe, MVPP2_PRS_RI_L3_UN,
                                ^
drivers/net/ethernet/marvell/mvpp2.c:529:30: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_L3_UN   ~(BIT(12) | BIT(13) | BIT(14))
                              ^
drivers/net/ethernet/marvell/mvpp2.c:2488:42: note: in expansion of macro 'MVPP2_PRS_RI_L3_UN'
  mvpp2_prs_shadow_ri_set(priv, pe.index, MVPP2_PRS_RI_L3_UN,
                                          ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_prs_vlan_init':
drivers/net/ethernet/marvell/mvpp2.c:517:34: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_VLAN_NONE   ~(BIT(2) | BIT(3))
                                  ^
drivers/net/ethernet/marvell/mvpp2.c:2563:32: note: in expansion of macro 'MVPP2_PRS_RI_VLAN_NONE'
  mvpp2_prs_sram_ri_update(&pe, MVPP2_PRS_RI_VLAN_NONE,
                                ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_prs_pppoe_init':
drivers/net/ethernet/marvell/mvpp2.c:529:30: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_L3_UN   ~(BIT(12) | BIT(13) | BIT(14))
                              ^
drivers/net/ethernet/marvell/mvpp2.c:2669:32: note: in expansion of macro 'MVPP2_PRS_RI_L3_UN'
  mvpp2_prs_sram_ri_update(&pe, MVPP2_PRS_RI_L3_UN,
                                ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_prs_ip4_init':
drivers/net/ethernet/marvell/mvpp2.c:537:33: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_L3_UCAST   ~(BIT(15) | BIT(16))
                                 ^
drivers/net/ethernet/marvell/mvpp2.c:2755:32: note: in expansion of macro 'MVPP2_PRS_RI_L3_UCAST'
  mvpp2_prs_sram_ri_update(&pe, MVPP2_PRS_RI_L3_UCAST,
                                ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_prs_ip6_init':
drivers/net/ethernet/marvell/mvpp2.c:529:30: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_L3_UN   ~(BIT(12) | BIT(13) | BIT(14))
                              ^
drivers/net/ethernet/marvell/mvpp2.c:2823:32: note: in expansion of macro 'MVPP2_PRS_RI_L3_UN'
  mvpp2_prs_sram_ri_update(&pe, MVPP2_PRS_RI_L3_UN |
                                ^
drivers/net/ethernet/marvell/mvpp2.c:537:33: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_L3_UCAST   ~(BIT(15) | BIT(16))
                                 ^
drivers/net/ethernet/marvell/mvpp2.c:2887:32: note: in expansion of macro 'MVPP2_PRS_RI_L3_UCAST'
  mvpp2_prs_sram_ri_update(&pe, MVPP2_PRS_RI_L3_UCAST,
                                ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_prs_mac_da_accept':
drivers/net/ethernet/marvell/mvpp2.c:524:33: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_L2_UCAST   ~(BIT(9) | BIT(10))
                                 ^
drivers/net/ethernet/marvell/mvpp2.c:3100:8: note: in expansion of macro 'MVPP2_PRS_RI_L2_UCAST'
   ri = MVPP2_PRS_RI_L2_UCAST | MVPP2_PRS_RI_MAC_ME_MASK;
        ^
In file included from drivers/net/ethernet/marvell/mvpp2.c:13:0:
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_bm_pool_create':
drivers/net/ethernet/marvell/mvpp2.c:3375:18: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
  if (!IS_ALIGNED((u32)bm_pool->virt_addr, MVPP2_BM_POOL_PTR_ALIGN)) {
                  ^
include/linux/kernel.h:51:30: note: in definition of macro 'IS_ALIGNED'
 #define IS_ALIGNED(x, a)  (((x) & ((typeof(x))(a) - 1)) == 0)
                              ^
drivers/net/ethernet/marvell/mvpp2.c:3375:18: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
  if (!IS_ALIGNED((u32)bm_pool->virt_addr, MVPP2_BM_POOL_PTR_ALIGN)) {
                  ^
include/linux/kernel.h:51:44: note: in definition of macro 'IS_ALIGNED'
 #define IS_ALIGNED(x, a)  (((x) & ((typeof(x))(a) - 1)) == 0)
                                            ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_bm_bufs_free':
drivers/net/ethernet/marvell/mvpp2.c:3433:21: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
   dev_kfree_skb_any((struct sk_buff *)vaddr);
                     ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_bm_bufs_add':
drivers/net/ethernet/marvell/mvpp2.c:3647:47: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
   mvpp2_pool_refill(port, bm, (u32)phys_addr, (u32)skb);
                                               ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_rx_refill':
drivers/net/ethernet/marvell/mvpp2.c:5011:46: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
  mvpp2_pool_refill(port, bm, (u32)phys_addr, (u32)skb);
                                              ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_buff_hdr_rx':
drivers/net/ethernet/marvell/mvpp2.c:5066:9: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
   skb = (struct sk_buff *)buff_virt_addr;
         ^
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_rx':
drivers/net/ethernet/marvell/mvpp2.c:5136:9: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
   skb = (struct sk_buff *)rx_desc->buf_cookie;
         ^

Introduced by commit

  a0627f776a45 ("net: marvell: Allow drivers to be built with COMPILE_TEST")

"a few warnings" is a matter of perception.  :-(

Please fix these up.
-- 
Cheers,
Stephen Rothwell
