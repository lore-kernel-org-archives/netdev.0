From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 2/4] mcs7830: unify return value of .ndo_set_mac_address if address is invalid
Date: Tue, 21 Feb 2012 13:07:50 +0100
Message-ID: <1329826072-14689-3-git-send-email-danny.kukawka@bisect.de>
References: <1329826072-14689-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, linux-usb@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329826072-14689-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unify return value of .ndo_set_mac_address if the given address
isn't valid. Return -EADDRNOTAVAIL as eth_mac_addr() already does
if is_valid_ether_addr() fails.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/usb/mcs7830.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index a29aa9c..c434b6b 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -239,7 +239,7 @@ static int mcs7830_set_mac_address(struct net_device *netdev, void *p)
 		return -EBUSY;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	ret = mcs7830_hif_set_mac_address(dev, addr->sa_data);
 
-- 
1.7.8.3
