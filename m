From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,
 1/1] hyperv: Add an error message to rndis_filter_set_device_mac()
Date: Fri, 30 Nov 2012 11:23:41 -0800
Message-ID: <1354303421-26149-1-git-send-email-haiyangz@microsoft.com>
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

This message indicates an error returned from the host when changing MAC address.

Reported-by: Michal Kubecek <mkubecek@suse.com>
Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/rndis_filter.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 7fdeb52..2b657d4 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -605,8 +605,11 @@ int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac)
 		return -EBUSY;
 	} else {
 		set_complete = &request->response_msg.msg.set_complete;
-		if (set_complete->status != RNDIS_STATUS_SUCCESS)
+		if (set_complete->status != RNDIS_STATUS_SUCCESS) {
+			netdev_err(ndev, "Fail to set MAC on host side:0x%x\n",
+				   set_complete->status);
 			ret = -EINVAL;
+		}
 	}
 
 cleanup:
-- 
1.7.4.1
