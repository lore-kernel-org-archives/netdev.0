From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH V2 2/2] e100 in linux-3.18.0: Add
 netif_napi_del in the normal path and error path to match netif_napi_add
Date: Sun, 21 Dec 2014 09:51:24 +0800
Message-ID: <5496279C.6070402@163.com>
References: <000201d01c61$bdb956b0$392c0410$@163.com>
	<20141220.143005.1130435723139487537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8367771131008664297=="
Cc: bjj13@mails.tsinghua.edu.cn, linux.nics@intel.com,
	sergei.shtylyov@cogentembedded.com, e1000-devel@lists.sourceforge.net,
	Linux-nics@isotope.jf.intel.com
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
--===============8367771131008664297==
Content-Type: multipart/alternative;
	boundary="------------000508050200090701080300"

This is a multi-part message in MIME format.
--------------000508050200090701080300
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 7bit

The driver lacks netif_napi_del in the normal path and error path to 
match the call of netif_napi_add in e100_probe.
This patch fixes this problem, and it has been tested in runtime.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
drivers/net/ethernet/intel/e100.c | 2 ++
1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/e100.c 
b/drivers/net/ethernet/intel/e100.c
index 781065e..21c4d0f 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2985,6 +2985,7 @@ err_out_free_res:
err_out_disable_pdev:
pci_disable_device(pdev);
err_out_free_dev:
+ netif_napi_del(&nic->napi);
free_netdev(netdev);
return err;
}
@@ -2995,6 +2996,7 @@ static void e100_remove(struct pci_dev *pdev)

if (netdev) {
struct nic *nic = netdev_priv(netdev);
+ netif_napi_del(&nic->napi);
unregister_netdev(netdev);
e100_free(nic);
pci_iounmap(pdev, nic->csr);

--------------000508050200090701080300--



--===============8367771131008664297==
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
--===============8367771131008664297==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============8367771131008664297==--
