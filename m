From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH V2 1/2] e100 in linux-3.18.0: Fix null pointer
 deference in e100_probe
Date: Sun, 21 Dec 2014 09:19:59 +0800
Message-ID: <5496203F.9000000@163.com>
References: <000201d01c61$bdb956b0$392c0410$@163.com>
	<20141220.143005.1130435723139487537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2515084146431594666=="
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

This is a multi-part message in MIME format.
--===============2515084146431594666==
Content-Type: multipart/alternative;
	boundary="------------040603000804010905010806"

This is a multi-part message in MIME format.
--------------040603000804010905010806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The driver lacks the check of nic->cbs_pool after pci_pool_create in e100_probe. So when this function is failed, the null pointer dereference occurs when pci_pool_alloc uses nic->cbs_pool in e100_alloc_cbs.
This patch fix this problem, and it has been tested in runtime.

Signed-off-by: Jia-Ju Bai<baijiaju1990@163.com>
---
  drivers/net/ethernet/intel/e100.c     |   6 ++++++
  1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 781065e..ba1813f 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2969,6 +2969,10 @@ static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
                nic->params.cbs.max * sizeof(struct cb),
                sizeof(u32),
                0);
+   if (!nic->cbs_pool) {
+       err = -ENOMEM;
+       goto err_out_pool;
+   }
     netif_info(nic, probe, nic->netdev,
            "addr 0x%llx, irq %d, MAC addr %pM\n",
            (unsigned long long)pci_resource_start(pdev, use_io ? 1 : 0),
@@ -2976,6 +2980,8 @@ static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)

     return 0;

+err_out_pool:
+   unregister_netdev(netdev);
  err_out_free:
     e100_free(nic);
  err_out_iounmap:



--------------040603000804010905010806--



--===============2515084146431594666==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=164703151&iu=/4140/ostg.clktrk
--===============2515084146431594666==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============2515084146431594666==--
