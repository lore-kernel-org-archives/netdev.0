From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net, 1/3] hyperv: Fix the max_xfer_size in RNDIS initialization
Date: Mon,  1 Oct 2012 15:30:55 -0700
Message-ID: <1349130657-7987-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

According to RNDIS specs, Windows sets this size to
0x4000. I use the same value here.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/rndis_filter.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 1e88a10..3cb7486 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -678,8 +678,7 @@ static int rndis_filter_init_device(struct rndis_device *dev)
 	init = &request->request_msg.msg.init_req;
 	init->major_ver = RNDIS_MAJOR_VERSION;
 	init->minor_ver = RNDIS_MINOR_VERSION;
-	/* FIXME: Use 1536 - rounded ethernet frame size */
-	init->max_xfer_size = 2048;
+	init->max_xfer_size = 0x4000;
 
 	dev->state = RNDIS_DEV_INITIALIZING;
 
-- 
1.7.4.1
