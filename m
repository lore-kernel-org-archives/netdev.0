From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 5/6] drivers: net: xgene-v2: Add transmit and
 receive
Date: Wed, 1 Feb 2017 04:44:10 +0800
Message-ID: <201702010402.H1dN6RUP%fengguang.wu@intel.com>
References: <1485889401-13909-6-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47730 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750730AbdAaUsW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 15:48:22 -0500
Content-Disposition: inline
In-Reply-To: <1485889401-13909-6-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Iyappan,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Iyappan-Subramanian/drivers-net-xgene-v2-Add-RGMII-based-1G-driver/20170201-034317
config: i386-allmodconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   In file included from include/linux/byteorder/little_endian.h:4:0,
                    from arch/x86/include/uapi/asm/byteorder.h:4,
                    from include/asm-generic/bitops/le.h:5,
                    from arch/x86/include/asm/bitops.h:517,
                    from include/linux/bitops.h:36,
                    from include/linux/kernel.h:10,
                    from include/linux/list.h:8,
                    from include/linux/resource_ext.h:17,
                    from include/linux/acpi.h:26,
                    from drivers/net/ethernet/apm/xgene-v2/main.h:25,
                    from drivers/net/ethernet/apm/xgene-v2/main.c:22:
   drivers/net/ethernet/apm/xgene-v2/main.c: In function 'xge_refill_buffers':
>> drivers/net/ethernet/apm/xgene-v2/main.c:162:20: warning: right shift count >= width of type [-Wshift-count-overflow]
              dma_addr >> PKT_ADDRL_LEN));
                       ^
   include/uapi/linux/byteorder/little_endian.h:30:51: note: in definition of macro '__cpu_to_le64'
    #define __cpu_to_le64(x) ((__force __le64)(__u64)(x))
                                                      ^
>> drivers/net/ethernet/apm/xgene-v2/main.c:161:9: note: in expansion of macro 'SET_BITS'
            SET_BITS(PKT_ADDRH,
            ^~~~~~~~
   drivers/net/ethernet/apm/xgene-v2/main.c: In function 'xge_start_xmit':
   drivers/net/ethernet/apm/xgene-v2/main.c:346:19: warning: right shift count >= width of type [-Wshift-count-overflow]
             dma_addr >> PKT_ADDRL_LEN));
                      ^
   include/uapi/linux/byteorder/little_endian.h:30:51: note: in definition of macro '__cpu_to_le64'
    #define __cpu_to_le64(x) ((__force __le64)(__u64)(x))
                                                      ^
   drivers/net/ethernet/apm/xgene-v2/main.c:345:8: note: in expansion of macro 'SET_BITS'
           SET_BITS(PKT_ADDRH,
           ^~~~~~~~
   drivers/net/ethernet/apm/xgene-v2/main.c: In function 'xge_rx_poll':
>> drivers/net/ethernet/apm/xgene-v2/main.c:453:23: warning: left shift count >= width of type [-Wshift-count-overflow]
      dma_addr = (addr_hi << PKT_ADDRL_LEN) | addr_lo;
                          ^~
--
   drivers/net/ethernet/apm/xgene-v2/ring.c: In function 'xge_setup_desc':
>> drivers/net/ethernet/apm/xgene-v2/ring.c:40:20: warning: right shift count >= width of type [-Wshift-count-overflow]
      dma_h = next_dma >> NEXT_DESC_ADDRL_LEN;
                       ^~
   drivers/net/ethernet/apm/xgene-v2/ring.c: In function 'xge_update_tx_desc_addr':
   drivers/net/ethernet/apm/xgene-v2/ring.c:51:42: warning: right shift count >= width of type [-Wshift-count-overflow]
     xge_wr_csr(pdata, DMATXDESCH, (dma_addr >> NEXT_DESC_ADDRL_LEN));
                                             ^~
   drivers/net/ethernet/apm/xgene-v2/ring.c: In function 'xge_update_rx_desc_addr':
   drivers/net/ethernet/apm/xgene-v2/ring.c:59:42: warning: right shift count >= width of type [-Wshift-count-overflow]
     xge_wr_csr(pdata, DMARXDESCH, (dma_addr >> NEXT_DESC_ADDRL_LEN));
                                             ^~

vim +162 drivers/net/ethernet/apm/xgene-v2/main.c

90db21d34 Iyappan Subramanian 2017-01-31   16   * GNU General Public License for more details.
90db21d34 Iyappan Subramanian 2017-01-31   17   *
90db21d34 Iyappan Subramanian 2017-01-31   18   * You should have received a copy of the GNU General Public License
90db21d34 Iyappan Subramanian 2017-01-31   19   * along with this program.  If not, see <http://www.gnu.org/licenses/>.
90db21d34 Iyappan Subramanian 2017-01-31   20   */
90db21d34 Iyappan Subramanian 2017-01-31   21  
90db21d34 Iyappan Subramanian 2017-01-31  @22  #include "main.h"
90db21d34 Iyappan Subramanian 2017-01-31   23  
90db21d34 Iyappan Subramanian 2017-01-31   24  static const struct acpi_device_id xge_acpi_match[];
90db21d34 Iyappan Subramanian 2017-01-31   25  
90db21d34 Iyappan Subramanian 2017-01-31   26  static int xge_get_resources(struct xge_pdata *pdata)
90db21d34 Iyappan Subramanian 2017-01-31   27  {
90db21d34 Iyappan Subramanian 2017-01-31   28  	struct platform_device *pdev;
90db21d34 Iyappan Subramanian 2017-01-31   29  	struct net_device *ndev;
90db21d34 Iyappan Subramanian 2017-01-31   30  	struct device *dev;
90db21d34 Iyappan Subramanian 2017-01-31   31  	struct resource *res;
90db21d34 Iyappan Subramanian 2017-01-31   32  	int phy_mode, ret = 0;
90db21d34 Iyappan Subramanian 2017-01-31   33  
90db21d34 Iyappan Subramanian 2017-01-31   34  	pdev = pdata->pdev;
90db21d34 Iyappan Subramanian 2017-01-31   35  	dev = &pdev->dev;
90db21d34 Iyappan Subramanian 2017-01-31   36  	ndev = pdata->ndev;
90db21d34 Iyappan Subramanian 2017-01-31   37  
90db21d34 Iyappan Subramanian 2017-01-31   38  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
90db21d34 Iyappan Subramanian 2017-01-31   39  	if (!res) {
90db21d34 Iyappan Subramanian 2017-01-31   40  		dev_err(dev, "Resource enet_csr not defined\n");
90db21d34 Iyappan Subramanian 2017-01-31   41  		return -ENODEV;
90db21d34 Iyappan Subramanian 2017-01-31   42  	}
90db21d34 Iyappan Subramanian 2017-01-31   43  
90db21d34 Iyappan Subramanian 2017-01-31   44  	pdata->resources.base_addr = devm_ioremap(dev, res->start,
90db21d34 Iyappan Subramanian 2017-01-31   45  						  resource_size(res));
90db21d34 Iyappan Subramanian 2017-01-31   46  	if (!pdata->resources.base_addr) {
90db21d34 Iyappan Subramanian 2017-01-31   47  		dev_err(dev, "Unable to retrieve ENET Port CSR region\n");
90db21d34 Iyappan Subramanian 2017-01-31   48  		return -ENOMEM;
90db21d34 Iyappan Subramanian 2017-01-31   49  	}
90db21d34 Iyappan Subramanian 2017-01-31   50  
90db21d34 Iyappan Subramanian 2017-01-31   51  	if (!device_get_mac_address(dev, ndev->dev_addr, ETH_ALEN))
90db21d34 Iyappan Subramanian 2017-01-31   52  		eth_hw_addr_random(ndev);
90db21d34 Iyappan Subramanian 2017-01-31   53  
90db21d34 Iyappan Subramanian 2017-01-31   54  	memcpy(ndev->perm_addr, ndev->dev_addr, ndev->addr_len);
90db21d34 Iyappan Subramanian 2017-01-31   55  
90db21d34 Iyappan Subramanian 2017-01-31   56  	phy_mode = device_get_phy_mode(dev);
90db21d34 Iyappan Subramanian 2017-01-31   57  	if (phy_mode < 0) {
90db21d34 Iyappan Subramanian 2017-01-31   58  		dev_err(dev, "Unable to get phy-connection-type\n");
90db21d34 Iyappan Subramanian 2017-01-31   59  		return phy_mode;
90db21d34 Iyappan Subramanian 2017-01-31   60  	}
90db21d34 Iyappan Subramanian 2017-01-31   61  	pdata->resources.phy_mode = phy_mode;
90db21d34 Iyappan Subramanian 2017-01-31   62  
90db21d34 Iyappan Subramanian 2017-01-31   63  	if (pdata->resources.phy_mode != PHY_INTERFACE_MODE_RGMII) {
90db21d34 Iyappan Subramanian 2017-01-31   64  		dev_err(dev, "Incorrect phy-connection-type specified\n");
90db21d34 Iyappan Subramanian 2017-01-31   65  		return -ENODEV;
90db21d34 Iyappan Subramanian 2017-01-31   66  	}
90db21d34 Iyappan Subramanian 2017-01-31   67  
90db21d34 Iyappan Subramanian 2017-01-31   68  	ret = platform_get_irq(pdev, 0);
90db21d34 Iyappan Subramanian 2017-01-31   69  	if (ret <= 0) {
90db21d34 Iyappan Subramanian 2017-01-31   70  		dev_err(dev, "Unable to get ENET IRQ\n");
90db21d34 Iyappan Subramanian 2017-01-31   71  		ret = ret ? : -ENXIO;
90db21d34 Iyappan Subramanian 2017-01-31   72  		return ret;
90db21d34 Iyappan Subramanian 2017-01-31   73  	}
90db21d34 Iyappan Subramanian 2017-01-31   74  	pdata->resources.irq = ret;
90db21d34 Iyappan Subramanian 2017-01-31   75  
90db21d34 Iyappan Subramanian 2017-01-31   76  	return 0;
90db21d34 Iyappan Subramanian 2017-01-31   77  }
90db21d34 Iyappan Subramanian 2017-01-31   78  
90db21d34 Iyappan Subramanian 2017-01-31   79  static void xge_delete_desc_rings(struct net_device *ndev)
90db21d34 Iyappan Subramanian 2017-01-31   80  {
90db21d34 Iyappan Subramanian 2017-01-31   81  	struct xge_pdata *pdata = netdev_priv(ndev);
90db21d34 Iyappan Subramanian 2017-01-31   82  	struct device *dev = &pdata->pdev->dev;
90db21d34 Iyappan Subramanian 2017-01-31   83  	struct xge_desc_ring *ring;
90db21d34 Iyappan Subramanian 2017-01-31   84  
90db21d34 Iyappan Subramanian 2017-01-31   85  	ring = pdata->tx_ring;
90db21d34 Iyappan Subramanian 2017-01-31   86  	if (ring) {
90db21d34 Iyappan Subramanian 2017-01-31   87  		if (ring->skbs)
90db21d34 Iyappan Subramanian 2017-01-31   88  			devm_kfree(dev, ring->skbs);
90db21d34 Iyappan Subramanian 2017-01-31   89  		if (ring->pkt_bufs)
90db21d34 Iyappan Subramanian 2017-01-31   90  			devm_kfree(dev, ring->pkt_bufs);
90db21d34 Iyappan Subramanian 2017-01-31   91  		devm_kfree(dev, ring);
90db21d34 Iyappan Subramanian 2017-01-31   92  	}
90db21d34 Iyappan Subramanian 2017-01-31   93  
90db21d34 Iyappan Subramanian 2017-01-31   94  	ring = pdata->rx_ring;
90db21d34 Iyappan Subramanian 2017-01-31   95  	if (ring) {
90db21d34 Iyappan Subramanian 2017-01-31   96  		if (ring->skbs)
90db21d34 Iyappan Subramanian 2017-01-31   97  			devm_kfree(dev, ring->skbs);
90db21d34 Iyappan Subramanian 2017-01-31   98  		devm_kfree(dev, ring);
90db21d34 Iyappan Subramanian 2017-01-31   99  	}
90db21d34 Iyappan Subramanian 2017-01-31  100  }
90db21d34 Iyappan Subramanian 2017-01-31  101  
90db21d34 Iyappan Subramanian 2017-01-31  102  static struct xge_desc_ring *xge_create_desc_ring(struct net_device *ndev)
90db21d34 Iyappan Subramanian 2017-01-31  103  {
90db21d34 Iyappan Subramanian 2017-01-31  104  	struct xge_pdata *pdata = netdev_priv(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  105  	struct device *dev = &pdata->pdev->dev;
90db21d34 Iyappan Subramanian 2017-01-31  106  	struct xge_desc_ring *ring;
90db21d34 Iyappan Subramanian 2017-01-31  107  	u16 size;
90db21d34 Iyappan Subramanian 2017-01-31  108  
90db21d34 Iyappan Subramanian 2017-01-31  109  	ring = devm_kzalloc(dev, sizeof(struct xge_desc_ring), GFP_KERNEL);
90db21d34 Iyappan Subramanian 2017-01-31  110  	if (!ring)
90db21d34 Iyappan Subramanian 2017-01-31  111  		return NULL;
90db21d34 Iyappan Subramanian 2017-01-31  112  
90db21d34 Iyappan Subramanian 2017-01-31  113  	ring->ndev = ndev;
90db21d34 Iyappan Subramanian 2017-01-31  114  
90db21d34 Iyappan Subramanian 2017-01-31  115  	size = XGENE_ENET_DESC_SIZE * XGENE_ENET_NUM_DESC;
90db21d34 Iyappan Subramanian 2017-01-31  116  	ring->desc_addr = dmam_alloc_coherent(dev, size, &ring->dma_addr,
90db21d34 Iyappan Subramanian 2017-01-31  117  					      GFP_KERNEL | __GFP_ZERO);
90db21d34 Iyappan Subramanian 2017-01-31  118  	if (!ring->desc_addr) {
90db21d34 Iyappan Subramanian 2017-01-31  119  		devm_kfree(dev, ring);
90db21d34 Iyappan Subramanian 2017-01-31  120  		return NULL;
90db21d34 Iyappan Subramanian 2017-01-31  121  	}
90db21d34 Iyappan Subramanian 2017-01-31  122  
90db21d34 Iyappan Subramanian 2017-01-31  123  	xge_setup_desc(ring);
90db21d34 Iyappan Subramanian 2017-01-31  124  
90db21d34 Iyappan Subramanian 2017-01-31  125  	return ring;
90db21d34 Iyappan Subramanian 2017-01-31  126  }
90db21d34 Iyappan Subramanian 2017-01-31  127  
90db21d34 Iyappan Subramanian 2017-01-31  128  static int xge_refill_buffers(struct net_device *ndev, u32 nbuf)
90db21d34 Iyappan Subramanian 2017-01-31  129  {
90db21d34 Iyappan Subramanian 2017-01-31  130  	struct xge_pdata *pdata = netdev_priv(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  131  	struct xge_desc_ring *ring = pdata->rx_ring;
90db21d34 Iyappan Subramanian 2017-01-31  132  	const u8 slots = XGENE_ENET_NUM_DESC - 1;
90db21d34 Iyappan Subramanian 2017-01-31  133  	struct device *dev = &pdata->pdev->dev;
90db21d34 Iyappan Subramanian 2017-01-31  134  	struct xge_raw_desc *raw_desc;
90db21d34 Iyappan Subramanian 2017-01-31  135  	u64 addr_lo, addr_hi;
90db21d34 Iyappan Subramanian 2017-01-31  136  	u8 tail = ring->tail;
90db21d34 Iyappan Subramanian 2017-01-31  137  	struct sk_buff *skb;
90db21d34 Iyappan Subramanian 2017-01-31  138  	dma_addr_t dma_addr;
90db21d34 Iyappan Subramanian 2017-01-31  139  	u16 len;
90db21d34 Iyappan Subramanian 2017-01-31  140  	int i;
90db21d34 Iyappan Subramanian 2017-01-31  141  
90db21d34 Iyappan Subramanian 2017-01-31  142  	for (i = 0; i < nbuf; i++) {
90db21d34 Iyappan Subramanian 2017-01-31  143  		raw_desc = &ring->raw_desc[tail];
90db21d34 Iyappan Subramanian 2017-01-31  144  
90db21d34 Iyappan Subramanian 2017-01-31  145  		len = XGENE_ENET_STD_MTU;
90db21d34 Iyappan Subramanian 2017-01-31  146  		skb = netdev_alloc_skb(ndev, len);
90db21d34 Iyappan Subramanian 2017-01-31  147  		if (unlikely(!skb))
90db21d34 Iyappan Subramanian 2017-01-31  148  			return -ENOMEM;
90db21d34 Iyappan Subramanian 2017-01-31  149  
90db21d34 Iyappan Subramanian 2017-01-31  150  		dma_addr = dma_map_single(dev, skb->data, len, DMA_FROM_DEVICE);
90db21d34 Iyappan Subramanian 2017-01-31  151  		if (dma_mapping_error(dev, dma_addr)) {
90db21d34 Iyappan Subramanian 2017-01-31  152  			netdev_err(ndev, "DMA mapping error\n");
90db21d34 Iyappan Subramanian 2017-01-31  153  			dev_kfree_skb_any(skb);
90db21d34 Iyappan Subramanian 2017-01-31  154  			return -EINVAL;
90db21d34 Iyappan Subramanian 2017-01-31  155  		}
90db21d34 Iyappan Subramanian 2017-01-31  156  
90db21d34 Iyappan Subramanian 2017-01-31  157  		addr_hi = GET_BITS(NEXT_DESC_ADDRH, le64_to_cpu(raw_desc->m1));
90db21d34 Iyappan Subramanian 2017-01-31  158  		addr_lo = GET_BITS(NEXT_DESC_ADDRL, le64_to_cpu(raw_desc->m1));
90db21d34 Iyappan Subramanian 2017-01-31  159  		raw_desc->m1 = cpu_to_le64(SET_BITS(NEXT_DESC_ADDRL, addr_lo) |
90db21d34 Iyappan Subramanian 2017-01-31  160  					   SET_BITS(NEXT_DESC_ADDRH, addr_hi) |
90db21d34 Iyappan Subramanian 2017-01-31 @161  					   SET_BITS(PKT_ADDRH,
90db21d34 Iyappan Subramanian 2017-01-31 @162  						    dma_addr >> PKT_ADDRL_LEN));
90db21d34 Iyappan Subramanian 2017-01-31  163  
90db21d34 Iyappan Subramanian 2017-01-31  164  		dma_wmb();
90db21d34 Iyappan Subramanian 2017-01-31  165  		raw_desc->m0 = cpu_to_le64(SET_BITS(PKT_ADDRL, dma_addr) |
90db21d34 Iyappan Subramanian 2017-01-31  166  					   SET_BITS(E, 1));
dde456a0a Iyappan Subramanian 2017-01-31  167  
90db21d34 Iyappan Subramanian 2017-01-31  168  		ring->skbs[tail] = skb;
90db21d34 Iyappan Subramanian 2017-01-31  169  		tail = (tail + 1) & slots;
90db21d34 Iyappan Subramanian 2017-01-31  170  	}
dde456a0a Iyappan Subramanian 2017-01-31  171  	xge_wr_csr(pdata, DMARXCTRL, 1);
90db21d34 Iyappan Subramanian 2017-01-31  172  
90db21d34 Iyappan Subramanian 2017-01-31  173  	ring->tail = tail;
90db21d34 Iyappan Subramanian 2017-01-31  174  
90db21d34 Iyappan Subramanian 2017-01-31  175  	return 0;
90db21d34 Iyappan Subramanian 2017-01-31  176  }
90db21d34 Iyappan Subramanian 2017-01-31  177  
90db21d34 Iyappan Subramanian 2017-01-31  178  static int xge_create_desc_rings(struct net_device *ndev)
90db21d34 Iyappan Subramanian 2017-01-31  179  {
90db21d34 Iyappan Subramanian 2017-01-31  180  	struct xge_pdata *pdata = netdev_priv(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  181  	struct device *dev = &pdata->pdev->dev;
90db21d34 Iyappan Subramanian 2017-01-31  182  	struct xge_desc_ring *ring;
90db21d34 Iyappan Subramanian 2017-01-31  183  	int ret;
90db21d34 Iyappan Subramanian 2017-01-31  184  
90db21d34 Iyappan Subramanian 2017-01-31  185  	/* create tx ring */
90db21d34 Iyappan Subramanian 2017-01-31  186  	ring = xge_create_desc_ring(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  187  	if (!ring)
90db21d34 Iyappan Subramanian 2017-01-31  188  		return -ENOMEM;
90db21d34 Iyappan Subramanian 2017-01-31  189  
90db21d34 Iyappan Subramanian 2017-01-31  190  	ring->skbs = devm_kcalloc(dev, XGENE_ENET_NUM_DESC,
90db21d34 Iyappan Subramanian 2017-01-31  191  				  sizeof(struct sk_buff *), GFP_KERNEL);
90db21d34 Iyappan Subramanian 2017-01-31  192  	if (!ring->skbs)
90db21d34 Iyappan Subramanian 2017-01-31  193  		goto err;
90db21d34 Iyappan Subramanian 2017-01-31  194  
90db21d34 Iyappan Subramanian 2017-01-31  195  	ring->pkt_bufs = devm_kcalloc(dev, XGENE_ENET_NUM_DESC,
90db21d34 Iyappan Subramanian 2017-01-31  196  				  sizeof(void *), GFP_KERNEL);
90db21d34 Iyappan Subramanian 2017-01-31  197  	if (!ring->pkt_bufs)
90db21d34 Iyappan Subramanian 2017-01-31  198  		goto err;
90db21d34 Iyappan Subramanian 2017-01-31  199  
90db21d34 Iyappan Subramanian 2017-01-31  200  	pdata->tx_ring = ring;
90db21d34 Iyappan Subramanian 2017-01-31  201  	xge_update_tx_desc_addr(pdata);
90db21d34 Iyappan Subramanian 2017-01-31  202  
90db21d34 Iyappan Subramanian 2017-01-31  203  	/* create rx ring */
90db21d34 Iyappan Subramanian 2017-01-31  204  	ring = xge_create_desc_ring(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  205  	if (!ring)
90db21d34 Iyappan Subramanian 2017-01-31  206  		goto err;
90db21d34 Iyappan Subramanian 2017-01-31  207  
90db21d34 Iyappan Subramanian 2017-01-31  208  	ring->skbs = devm_kcalloc(dev, XGENE_ENET_NUM_DESC,
90db21d34 Iyappan Subramanian 2017-01-31  209  				  sizeof(struct sk_buff *), GFP_KERNEL);
90db21d34 Iyappan Subramanian 2017-01-31  210  	if (!ring->skbs)
90db21d34 Iyappan Subramanian 2017-01-31  211  		goto err;
90db21d34 Iyappan Subramanian 2017-01-31  212  
90db21d34 Iyappan Subramanian 2017-01-31  213  	pdata->rx_ring = ring;
90db21d34 Iyappan Subramanian 2017-01-31  214  	xge_update_rx_desc_addr(pdata);
90db21d34 Iyappan Subramanian 2017-01-31  215  
90db21d34 Iyappan Subramanian 2017-01-31  216  	ret = xge_refill_buffers(ndev, XGENE_ENET_NUM_DESC);
90db21d34 Iyappan Subramanian 2017-01-31  217  	if (!ret)
90db21d34 Iyappan Subramanian 2017-01-31  218  		return 0;
90db21d34 Iyappan Subramanian 2017-01-31  219  
90db21d34 Iyappan Subramanian 2017-01-31  220  err:
90db21d34 Iyappan Subramanian 2017-01-31  221  	xge_delete_desc_rings(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  222  
90db21d34 Iyappan Subramanian 2017-01-31  223  	return -ENOMEM;
90db21d34 Iyappan Subramanian 2017-01-31  224  }
90db21d34 Iyappan Subramanian 2017-01-31  225  
90db21d34 Iyappan Subramanian 2017-01-31  226  static int xge_init_hw(struct net_device *ndev)
90db21d34 Iyappan Subramanian 2017-01-31  227  {
90db21d34 Iyappan Subramanian 2017-01-31  228  	struct xge_pdata *pdata = netdev_priv(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  229  	int ret;
90db21d34 Iyappan Subramanian 2017-01-31  230  
90db21d34 Iyappan Subramanian 2017-01-31  231  	ret = xge_port_reset(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  232  	if (ret)
90db21d34 Iyappan Subramanian 2017-01-31  233  		return ret;
90db21d34 Iyappan Subramanian 2017-01-31  234  
90db21d34 Iyappan Subramanian 2017-01-31  235  	xge_create_desc_rings(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  236  	xge_port_init(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  237  	pdata->nbufs = NUM_BUFS;
90db21d34 Iyappan Subramanian 2017-01-31  238  
90db21d34 Iyappan Subramanian 2017-01-31  239  	return 0;
90db21d34 Iyappan Subramanian 2017-01-31  240  }
90db21d34 Iyappan Subramanian 2017-01-31  241  
90db21d34 Iyappan Subramanian 2017-01-31  242  static irqreturn_t xge_irq(const int irq, void *data)
90db21d34 Iyappan Subramanian 2017-01-31  243  {
90db21d34 Iyappan Subramanian 2017-01-31  244  	struct xge_pdata *pdata = data;
90db21d34 Iyappan Subramanian 2017-01-31  245  
90db21d34 Iyappan Subramanian 2017-01-31  246  	if (napi_schedule_prep(&pdata->napi)) {
90db21d34 Iyappan Subramanian 2017-01-31  247  		xge_intr_disable(pdata);
90db21d34 Iyappan Subramanian 2017-01-31  248  		__napi_schedule(&pdata->napi);
90db21d34 Iyappan Subramanian 2017-01-31  249  	}
90db21d34 Iyappan Subramanian 2017-01-31  250  
90db21d34 Iyappan Subramanian 2017-01-31  251  	return IRQ_HANDLED;
90db21d34 Iyappan Subramanian 2017-01-31  252  }
90db21d34 Iyappan Subramanian 2017-01-31  253  
90db21d34 Iyappan Subramanian 2017-01-31  254  static int xge_request_irq(struct net_device *ndev)
90db21d34 Iyappan Subramanian 2017-01-31  255  {
90db21d34 Iyappan Subramanian 2017-01-31  256  	struct xge_pdata *pdata = netdev_priv(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  257  	struct device *dev = &pdata->pdev->dev;
90db21d34 Iyappan Subramanian 2017-01-31  258  	int ret;
90db21d34 Iyappan Subramanian 2017-01-31  259  
90db21d34 Iyappan Subramanian 2017-01-31  260  	snprintf(pdata->irq_name, IRQ_ID_SIZE, "%s", ndev->name);
90db21d34 Iyappan Subramanian 2017-01-31  261  
90db21d34 Iyappan Subramanian 2017-01-31  262  	ret = devm_request_irq(dev, pdata->resources.irq, xge_irq,
90db21d34 Iyappan Subramanian 2017-01-31  263  			       0, pdata->irq_name, pdata);
90db21d34 Iyappan Subramanian 2017-01-31  264  	if (ret)
90db21d34 Iyappan Subramanian 2017-01-31  265  		netdev_err(ndev, "Failed to request irq %s\n", pdata->irq_name);
90db21d34 Iyappan Subramanian 2017-01-31  266  
90db21d34 Iyappan Subramanian 2017-01-31  267  	return ret;
90db21d34 Iyappan Subramanian 2017-01-31  268  }
90db21d34 Iyappan Subramanian 2017-01-31  269  
90db21d34 Iyappan Subramanian 2017-01-31  270  static void xge_free_irq(struct net_device *ndev)
90db21d34 Iyappan Subramanian 2017-01-31  271  {
90db21d34 Iyappan Subramanian 2017-01-31  272  	struct xge_pdata *pdata = netdev_priv(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  273  	struct device *dev = &pdata->pdev->dev;
90db21d34 Iyappan Subramanian 2017-01-31  274  
90db21d34 Iyappan Subramanian 2017-01-31  275  	devm_free_irq(dev, pdata->resources.irq, pdata);
90db21d34 Iyappan Subramanian 2017-01-31  276  }
90db21d34 Iyappan Subramanian 2017-01-31  277  
90db21d34 Iyappan Subramanian 2017-01-31  278  static int xge_open(struct net_device *ndev)
90db21d34 Iyappan Subramanian 2017-01-31  279  {
90db21d34 Iyappan Subramanian 2017-01-31  280  	struct xge_pdata *pdata = netdev_priv(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  281  	int ret;
90db21d34 Iyappan Subramanian 2017-01-31  282  
dde456a0a Iyappan Subramanian 2017-01-31  283  	napi_enable(&pdata->napi);
dde456a0a Iyappan Subramanian 2017-01-31  284  
90db21d34 Iyappan Subramanian 2017-01-31  285  	ret = xge_request_irq(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  286  	if (ret)
90db21d34 Iyappan Subramanian 2017-01-31  287  		return ret;
90db21d34 Iyappan Subramanian 2017-01-31  288  
90db21d34 Iyappan Subramanian 2017-01-31  289  	xge_intr_enable(pdata);
90db21d34 Iyappan Subramanian 2017-01-31  290  
90db21d34 Iyappan Subramanian 2017-01-31  291  	xge_mac_enable(pdata);
90db21d34 Iyappan Subramanian 2017-01-31  292  	netif_start_queue(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  293  
90db21d34 Iyappan Subramanian 2017-01-31  294  	return 0;
90db21d34 Iyappan Subramanian 2017-01-31  295  }
90db21d34 Iyappan Subramanian 2017-01-31  296  
90db21d34 Iyappan Subramanian 2017-01-31  297  static int xge_close(struct net_device *ndev)
90db21d34 Iyappan Subramanian 2017-01-31  298  {
90db21d34 Iyappan Subramanian 2017-01-31  299  	struct xge_pdata *pdata = netdev_priv(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  300  
90db21d34 Iyappan Subramanian 2017-01-31  301  	netif_stop_queue(ndev);
90db21d34 Iyappan Subramanian 2017-01-31  302  	xge_mac_disable(pdata);
90db21d34 Iyappan Subramanian 2017-01-31  303  
dde456a0a Iyappan Subramanian 2017-01-31  304  	xge_intr_disable(pdata);
90db21d34 Iyappan Subramanian 2017-01-31  305  	xge_free_irq(ndev);
dde456a0a Iyappan Subramanian 2017-01-31  306  	napi_disable(&pdata->napi);
90db21d34 Iyappan Subramanian 2017-01-31  307  
90db21d34 Iyappan Subramanian 2017-01-31  308  	return 0;
90db21d34 Iyappan Subramanian 2017-01-31  309  }
90db21d34 Iyappan Subramanian 2017-01-31  310  
dde456a0a Iyappan Subramanian 2017-01-31  311  static netdev_tx_t xge_start_xmit(struct sk_buff *skb, struct net_device *ndev)
dde456a0a Iyappan Subramanian 2017-01-31  312  {
dde456a0a Iyappan Subramanian 2017-01-31  313  	struct xge_pdata *pdata = netdev_priv(ndev);
dde456a0a Iyappan Subramanian 2017-01-31  314  	struct device *dev = &pdata->pdev->dev;
dde456a0a Iyappan Subramanian 2017-01-31  315  	static dma_addr_t dma_addr;
dde456a0a Iyappan Subramanian 2017-01-31  316  	struct xge_desc_ring *tx_ring;
dde456a0a Iyappan Subramanian 2017-01-31  317  	struct xge_raw_desc *raw_desc;
dde456a0a Iyappan Subramanian 2017-01-31  318  	u64 addr_lo, addr_hi;
dde456a0a Iyappan Subramanian 2017-01-31  319  	void *pkt_buf;
dde456a0a Iyappan Subramanian 2017-01-31  320  	u8 tail;
dde456a0a Iyappan Subramanian 2017-01-31  321  	u16 len;
dde456a0a Iyappan Subramanian 2017-01-31  322  
dde456a0a Iyappan Subramanian 2017-01-31  323  	tx_ring = pdata->tx_ring;
dde456a0a Iyappan Subramanian 2017-01-31  324  	tail = tx_ring->tail;
dde456a0a Iyappan Subramanian 2017-01-31  325  	len = skb_headlen(skb);
dde456a0a Iyappan Subramanian 2017-01-31  326  	raw_desc = &tx_ring->raw_desc[tail];
dde456a0a Iyappan Subramanian 2017-01-31  327  
dde456a0a Iyappan Subramanian 2017-01-31  328  	/* Tx descriptor not available */
dde456a0a Iyappan Subramanian 2017-01-31  329  	if (!GET_BITS(E, le64_to_cpu(raw_desc->m0)) ||
dde456a0a Iyappan Subramanian 2017-01-31  330  	    GET_BITS(PKT_SIZE, le64_to_cpu(raw_desc->m0)))
dde456a0a Iyappan Subramanian 2017-01-31  331  		return NETDEV_TX_BUSY;
dde456a0a Iyappan Subramanian 2017-01-31  332  
dde456a0a Iyappan Subramanian 2017-01-31  333  	/* Packet buffers should be 64B aligned */
dde456a0a Iyappan Subramanian 2017-01-31  334  	pkt_buf = dma_alloc_coherent(dev, XGENE_ENET_STD_MTU, &dma_addr,
dde456a0a Iyappan Subramanian 2017-01-31  335  				     GFP_ATOMIC);
dde456a0a Iyappan Subramanian 2017-01-31  336  	if (unlikely(!pkt_buf))
dde456a0a Iyappan Subramanian 2017-01-31  337  		goto out;
dde456a0a Iyappan Subramanian 2017-01-31  338  
dde456a0a Iyappan Subramanian 2017-01-31  339  	memcpy(pkt_buf, skb->data, len);
dde456a0a Iyappan Subramanian 2017-01-31  340  
dde456a0a Iyappan Subramanian 2017-01-31  341  	addr_hi = GET_BITS(NEXT_DESC_ADDRH, le64_to_cpu(raw_desc->m1));
dde456a0a Iyappan Subramanian 2017-01-31  342  	addr_lo = GET_BITS(NEXT_DESC_ADDRL, le64_to_cpu(raw_desc->m1));
dde456a0a Iyappan Subramanian 2017-01-31  343  	raw_desc->m1 = cpu_to_le64(SET_BITS(NEXT_DESC_ADDRL, addr_lo) |
dde456a0a Iyappan Subramanian 2017-01-31  344  				   SET_BITS(NEXT_DESC_ADDRH, addr_hi) |
dde456a0a Iyappan Subramanian 2017-01-31 @345  				   SET_BITS(PKT_ADDRH,
dde456a0a Iyappan Subramanian 2017-01-31  346  					    dma_addr >> PKT_ADDRL_LEN));
dde456a0a Iyappan Subramanian 2017-01-31  347  
dde456a0a Iyappan Subramanian 2017-01-31  348  	dma_wmb();

:::::: The code at line 162 was first introduced by commit
:::::: 90db21d344b12f41c93e821a69a96a60453e9dd8 drivers: net: xgene-v2: Add base driver

:::::: TO: Iyappan Subramanian <isubramanian@apm.com>
:::::: CC: 0day robot <fengguang.wu@intel.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--AhhlLboLdkugWU4S
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--AhhlLboLdkugWU4S--
