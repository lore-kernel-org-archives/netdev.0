From: weiyj_lk@163.com
Subject: [PATCH] hyperv: Fix error return code in netvsc_init_buf()
Date: Wed, 23 Jul 2014 09:00:35 +0800
Message-ID: <1406077235-29095-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
 netdev@vger.kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>,
 Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return -ENOMEM from the kalloc error handling
case instead of 0.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/hyperv/netvsc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 4ed38ea..d97d5f3 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -378,8 +378,10 @@ static int netvsc_init_buf(struct hv_device *device)
 
 	net_device->send_section_map =
 		kzalloc(net_device->map_words * sizeof(ulong), GFP_KERNEL);
-	if (net_device->send_section_map == NULL)
+	if (net_device->send_section_map == NULL) {
+		ret = -ENOMEM;
 		goto cleanup;
+	}
 
 	goto exit;
