From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 04/12] fddi/skfp: check given MAC address, if invalid return -EADDRNOTAVAIL
Date: Fri, 24 Feb 2012 17:01:14 +0100
Message-ID: <1330099282-4588-5-git-send-email-danny.kukawka@bisect.de>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check if given address is valid in .ndo_set_mac_address, if
invalid return -EADDRNOTAVAIL as eth_mac_addr() already does
if is_valid_ether_addr() fails.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/fddi/skfp/skfddi.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fddi/skfp/skfddi.c b/drivers/net/fddi/skfp/skfddi.c
index 3d9a459..1092d94 100644
--- a/drivers/net/fddi/skfp/skfddi.c
+++ b/drivers/net/fddi/skfp/skfddi.c
@@ -81,6 +81,7 @@ static const char * const boot_msg =
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/fddidevice.h>
 #include <linux/skbuff.h>
 #include <linux/bitops.h>
@@ -926,6 +927,8 @@ static int skfp_ctl_set_mac_address(struct net_device *dev, void *addr)
 	skfddi_priv *bp = &smc->os;
 	unsigned long Flags;
 
+	if (!is_valid_ether_addr(p_sockaddr->sa_data))
+		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, p_sockaddr->sa_data, FDDI_K_ALEN);
 	spin_lock_irqsave(&bp->DriverLock, Flags);
-- 
1.7.8.3
