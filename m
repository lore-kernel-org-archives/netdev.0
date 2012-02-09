From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 1/2] eth: reset addr_assign_type if eth_mac_addr() called
Date: Thu,  9 Feb 2012 20:48:53 +0100
Message-ID: <1328816934-11508-2-git-send-email-danny.kukawka@bisect.de>
References: <1328816934-11508-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Randy Dunlap <rdunlap@xenotime.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328816934-11508-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If eth_mac_addr() get called, usually if SIOCSIFHWADDR was
used to change the MAC of a ethernet device, reset the
addr_assign_type to NET_ADDR_PERM if the state was
NET_ADDR_RANDOM before. Reset the state since the MAC is
no longer random at least not from the kernel side.

v2: changed to bitops, removed if()

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 net/ethernet/eth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index a246836..a93af86 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -288,6 +288,8 @@ int eth_mac_addr(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	/* if device marked as NET_ADDR_RANDOM, reset it */
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	return 0;
 }
 EXPORT_SYMBOL(eth_mac_addr);
-- 
1.7.7.3
