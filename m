From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH V2] e1000: Add netif_napi_del in the normal
 path and error path to match netif_napi_add
Date: Sun, 21 Dec 2014 08:52:54 +0800
Message-ID: <549619E6.8070503@163.com>
References: <000201d01c61$bdb956b0$392c0410$@163.com>
	<20141220.143005.1130435723139487537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, linux.nics@intel.com,
	sergei.shtylyov@cogentembedded.com, Linux-nics@isotope.jf.intel.com
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20141220.143005.1130435723139487537.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Th driver lacks netif_napi_del in the normal path and error path to match the call of netif_napi_add in e1000_probe.

This patch fixes this problem, and it has been tested in runtime.

Signed-off-by: Jia-Ju Bai<baijiaju1990@163.com>

---

  drivers/net/ethernet/intel/e1000/e1000_main.c    |    6 +-

  1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c

index 24f3986..f6def7b 100644

--- a/drivers/net/ethernet/intel/e1000/e1000_main.c

+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c

@@ -1004,7 +1004,7 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)

  	/* make ready for any if (hw->...) below */

  	err = e1000_init_hw_struct(adapter, hw);

  	if (err)

-		goto err_sw_init;

+		goto err_dma;

  	/* there is a workaround being applied below that limits

  	* 64-bit DMA addresses to 64-bit hardware.  There are some

@@ -1239,8 +1239,9 @@ err_eeprom:

  		iounmap(hw->flash_address);

  	kfree(adapter->tx_ring);

  	kfree(adapter->rx_ring);

-err_dma:

  err_sw_init:

+	netif_napi_del(&adapter->napi);

+err_dma:

  err_mdio_ioremap:

  	iounmap(hw->ce4100_gbe_mdio_base_virt);

  	iounmap(hw->hw_addr);

@@ -1271,6 +1272,7 @@ static void e1000_remove(struct pci_dev *pdev)

  	e1000_down_and_stop(adapter);

  	e1000_release_manageability(adapter);

+	netif_napi_del(&adapter->napi);

  	unregister_netdev(netdev);

  	e1000_phy_hw_reset(hw);



------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=164703151&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
