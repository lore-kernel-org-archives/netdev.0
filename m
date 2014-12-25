From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH net v3 2/2] e100: Add netif_napi_del in the
	driver
Date: Thu, 25 Dec 2014 10:02:36 +0800
Message-ID: <1419472956-6270-2-git-send-email-baijiaju1990@163.com>
References: <1419472956-6270-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jia-Ju Bai <baijiaju1990@163.com>, linux.nics@intel.com
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com, mitch.a.williams@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1419472956-6270-1-git-send-email-baijiaju1990@163.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The driver lacks netif_napi_del in the normal path and error path to 
match the call of netif_napi_add in e100_probe.
This patch fixes this problem, and it has been tested on the hardware.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/intel/e100.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 781065e..21c4d0f 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2985,6 +2985,7 @@ err_out_free_res:
 err_out_disable_pdev:
 	pci_disable_device(pdev);
 err_out_free_dev:
+	netif_napi_del(&nic->napi);
 	free_netdev(netdev);
 	return err;
 }
@@ -2995,6 +2996,7 @@ static void e100_remove(struct pci_dev *pdev)
 
 	if (netdev) {
 		struct nic *nic = netdev_priv(netdev);
+		netif_napi_del(&nic->napi);
 		unregister_netdev(netdev);
 		e100_free(nic);
 		pci_iounmap(pdev, nic->csr);
-- 
1.7.9.5



------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
