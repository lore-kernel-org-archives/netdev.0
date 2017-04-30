From: kys@exchange.microsoft.com
Subject: [PATCH 3/6] Drivers: hv: vmbus: Fix error code returned by
 vmbus_post_msg()
Date: Sun, 30 Apr 2017 16:21:16 -0700
Message-ID: <1493594479-25329-3-git-send-email-kys@exchange.microsoft.com>
References: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
Reply-To: kys@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
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

From: K. Y. Srinivasan <kys@microsoft.com>

ENOBUFS is a more approrpiate error code to be returned
when the hypervisor cannot post the message because of
insufficient buffers. Make the adjustment.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/hv/connection.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/hv/connection.c b/drivers/hv/connection.c
index fce27fb..a938fcf 100644
--- a/drivers/hv/connection.c
+++ b/drivers/hv/connection.c
@@ -370,7 +370,7 @@ int vmbus_post_msg(void *buffer, size_t buflen, bool can_sleep)
 			break;
 		case HV_STATUS_INSUFFICIENT_MEMORY:
 		case HV_STATUS_INSUFFICIENT_BUFFERS:
-			ret = -ENOMEM;
+			ret = -ENOBUFS;
 			break;
 		case HV_STATUS_SUCCESS:
 			return ret;
-- 
1.7.1
