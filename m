From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 2/3] xen-netback: delete NAPI instance when
	queue fails to initialize
Date: Fri, 15 Jan 2016 14:55:35 +0000
Message-ID: <1452869736-20282-3-git-send-email-david.vrabel@citrix.com>
References: <1452869736-20282-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1452869736-20282-1-git-send-email-david.vrabel@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

When xenvif_connect() fails it may leave a stale NAPI instance added to
the device.  Make sure we delete it in the error path.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/interface.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index e7bd63e..3bba6ce 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -615,6 +615,7 @@ err_tx_unbind:
 	queue->tx_irq = 0;
 err_unmap:
 	xenvif_unmap_frontend_rings(queue);
+	netif_napi_del(&queue->napi);
 err:
 	module_put(THIS_MODULE);
 	return err;
-- 
2.1.4
