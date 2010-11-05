From: Joe Perches <joe@perches.com>
Subject: [PATCH 24/49] drivers/net/ixgb: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:48 -0700
Message-ID: <b63aacd8d05e27da93e3412a146e98939fba8e2a.1288925424.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ixgb/ixgb_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index caa8192..211a169 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -669,13 +669,12 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * txdr->count;
-	txdr->buffer_info = vmalloc(size);
+	txdr->buffer_info = vzalloc(size);
 	if (!txdr->buffer_info) {
 		netif_err(adapter, probe, adapter->netdev,
 			  "Unable to allocate transmit descriptor ring memory\n");
 		return -ENOMEM;
 	}
-	memset(txdr->buffer_info, 0, size);
 
 	/* round up to nearest 4K */
 
@@ -759,13 +758,12 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * rxdr->count;
-	rxdr->buffer_info = vmalloc(size);
+	rxdr->buffer_info = vzalloc(size);
 	if (!rxdr->buffer_info) {
 		netif_err(adapter, probe, adapter->netdev,
 			  "Unable to allocate receive descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(rxdr->buffer_info, 0, size);
 
 	/* Round up to nearest 4K */
 
-- 
1.7.3.1.g432b3.dirty


------------------------------------------------------------------------------
The Next 800 Companies to Lead America's Growth: New Video Whitepaper
David G. Thomson, author of the best-selling book "Blueprint to a 
Billion" shares his insights and actions to help propel your 
business during the next growth cycle. Listen Now!
http://p.sf.net/sfu/SAP-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
