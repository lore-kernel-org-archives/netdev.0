From: Robert Dobrowolski <robert.dobrowolski@linux.intel.com>
Subject: [PATCH v1] net: cdc_ncm: update datagram size after changing mtu
Date: Wed,  6 Apr 2016 13:41:09 +0200
Message-ID: <1459942869-13587-1-git-send-email-robert.dobrowolski@linux.intel.com>
Cc: robert.dobrowolski@linux.intel.com, rafal.f.redzimski@intel.com,
	stable@vger.kernel.org, oliver@neukum.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-usb@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafal Redzimski <rafal.f.redzimski@intel.com>

Current implementation updates the mtu size and notify cdc_ncm
device using USB_CDC_SET_MAX_DATAGRAM_SIZE request about datagram
size change instead of changing rx_urb_size.

Whenever mtu is being changed, datagram size should also be
updated.

Cc: <stable@vger.kernel.org>
Signed-off-by: Rafal Redzimski <rafal.f.redzimski@intel.com>
Signed-off-by: Robert Dobrowolski <robert.dobrowolski@linux.intel.com>
---
 drivers/net/usb/cdc_ncm.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 2fb31ed..4a47656 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -746,6 +746,8 @@ int cdc_ncm_change_mtu(struct net_device *net, int new_mtu)
 	if (new_mtu <= 0 || new_mtu > maxmtu)
 		return -EINVAL;
 	net->mtu = new_mtu;
+	cdc_ncm_set_dgram_size(dev, new_mtu);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(cdc_ncm_change_mtu);
-- 
1.9.1
