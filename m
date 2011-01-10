From: Axel Lin <axel.lin@gmail.com>
Subject: [PATCH] iwmc3200wifi: Return proper error for iwm_if_alloc
Date: Mon, 10 Jan 2011 10:26:00 +0800
Message-ID: <1294626360.25455.1.camel@mola>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel.ortiz@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the case of alloc_netdev_mq failure and kmalloc failure,
current implementation returns ERR_PTR(0).

As a result, the caller of iwm_if_alloc does not catch the error by IS_ERR
macro. Fix it by setting proper error code for ret variable in the failure
cases.

Signed-off-by: Axel Lin <axel.lin@gmail.com>
---
 drivers/net/wireless/iwmc3200wifi/netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/iwmc3200wifi/netdev.c b/drivers/net/wireless/iwmc3200wifi/netdev.c
index 13a69eb..5091d77 100644
--- a/drivers/net/wireless/iwmc3200wifi/netdev.c
+++ b/drivers/net/wireless/iwmc3200wifi/netdev.c
@@ -126,6 +126,7 @@ void *iwm_if_alloc(int sizeof_bus, struct device *dev,
 	ndev = alloc_netdev_mq(0, "wlan%d", ether_setup, IWM_TX_QUEUES);
 	if (!ndev) {
 		dev_err(dev, "no memory for network device instance\n");
+		ret = -ENOMEM;
 		goto out_priv;
 	}
 
@@ -138,6 +139,7 @@ void *iwm_if_alloc(int sizeof_bus, struct device *dev,
 				    GFP_KERNEL);
 	if (!iwm->umac_profile) {
 		dev_err(dev, "Couldn't alloc memory for profile\n");
+		ret = -ENOMEM;
 		goto out_profile;
 	}
 
-- 
1.7.2
