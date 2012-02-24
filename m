From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 02/12] cris/eth_v10: check given MAC address, if invalid return -EADDRNOTAVAIL
Date: Fri, 24 Feb 2012 17:01:12 +0100
Message-ID: <1330099282-4588-3-git-send-email-danny.kukawka@bisect.de>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Javier Martinez Canillas <martinez.javier@gmail.com>,
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
 drivers/net/cris/eth_v10.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 7cb2785..e450d8a 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -424,6 +424,9 @@ e100_set_mac_address(struct net_device *dev, void *p)
 	struct net_local *np = netdev_priv(dev);
 	struct sockaddr *addr = p;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	spin_lock(&np->lock); /* preemption protection */
 
 	/* remember it */
-- 
1.7.8.3
