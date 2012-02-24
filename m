From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 12/12] rose: check given MAC address, if invalid return -EADDRNOTAVAIL
Date: Fri, 24 Feb 2012 17:01:22 +0100
Message-ID: <1330099282-4588-13-git-send-email-danny.kukawka@bisect.de>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check if given address is valid in .ndo_set_mac_address/
rose_set_mac_address(), if invalid return -EADDRNOTAVAIL as
eth_mac_addr() already does if is_valid_ether_addr() fails.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 net/rose/rose_dev.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 178ff4f..1ae8791 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -96,6 +96,9 @@ static int rose_set_mac_address(struct net_device *dev, void *addr)
 	struct sockaddr *sa = addr;
 	int err;
 
+	if (!is_valid_ether_addr(sa->sa_data))
+		return -EADDRNOTAVAIL;
+
 	if (!memcpy(dev->dev_addr, sa->sa_data, dev->addr_len))
 		return 0;
 
-- 
1.7.8.3
