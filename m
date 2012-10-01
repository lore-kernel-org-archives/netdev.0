From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net, 2/3] hyperv: Fix the missing return value in
 rndis_filter_set_packet_filter()
Date: Mon,  1 Oct 2012 15:30:56 -0700
Message-ID: <1349130657-7987-2-git-send-email-haiyangz@microsoft.com>
References: <1349130657-7987-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1349130657-7987-1-git-send-email-haiyangz@microsoft.com>
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

Return ETIMEDOUT when the reply message is not received in time.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/rndis_filter.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 3cb7486..2909dd8 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -641,6 +641,7 @@ int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter)
 	if (t == 0) {
 		netdev_err(ndev,
 			"timeout before we got a set response...\n");
+		ret = -ETIMEDOUT;
 		/*
 		 * We can't deallocate the request since we may still receive a
 		 * send completion for it.
-- 
1.7.4.1
