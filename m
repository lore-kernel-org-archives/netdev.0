From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 06/14] xen: Use eth_<foo>_addr instead
	of memset
Date: Mon,  2 Mar 2015 19:54:51 -0800
Message-ID: <8762529463d8d2290ef0b67e5ed91f4bccb98b37.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/xen-netback/interface.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index f38227a..4ae98e2 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -438,7 +438,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	 * stolen by an Ethernet bridge for STP purposes.
 	 * (FE:FF:FF:FF:FF:FF)
 	 */
-	memset(dev->dev_addr, 0xFF, ETH_ALEN);
+	eth_broadcast_addr(dev->dev_addr);
 	dev->dev_addr[0] &= ~0x01;
 
 	netif_carrier_off(dev);
-- 
2.1.2
