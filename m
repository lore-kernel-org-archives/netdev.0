From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] netvsc: increase default receive buffer size
Date: Thu, 14 Sep 2017 09:31:07 -0700
Message-ID: <20170914163107.8404-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>,
 devel@linuxdriverproject.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	davem@davemloft.net
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The default receive buffer size was reduced by recent change
to a value which was appropriate for 10G and Windows Server 2016.
But the value is too small for full performance with 40G on Azure.
Increase the default back to maximum supported by host.

Fixes: 8b5327975ae1 ("netvsc: allow controlling send/recv buffer size")
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index c538a4f15f3b..d4902ee5f260 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -49,7 +49,7 @@
 #define NETVSC_MIN_TX_SECTIONS	10
 #define NETVSC_DEFAULT_TX	192	/* ~1M */
 #define NETVSC_MIN_RX_SECTIONS	10	/* ~64K */
-#define NETVSC_DEFAULT_RX	2048	/* ~4M */
+#define NETVSC_DEFAULT_RX	10485   /* Max ~16M */
 
 #define LINKCHANGE_INT (2 * HZ)
 #define VF_TAKEOVER_INT (HZ / 10)
-- 
2.11.0
