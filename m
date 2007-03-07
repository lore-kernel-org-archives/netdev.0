From: Josh Triplett <josh@freedesktop.org>
Subject: [PATCH] Allow pktgen to work with loopback devices.
Date: Wed, 07 Mar 2007 04:29:05 -0800
Message-ID: <45EEB011.5020606@freedesktop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965026AbXCGM3q@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pktgen currently only works on network devices with type ARPHRD_ETHER.  Add
support for the loopback device, type ARPHRD_LOOPBACK.

I've tested this on my system, using a modified pktgen.conf-1-1 with
s/eth1/lo/g, and it works fine; the network device statistics confirm packet
transmission and receipt.

Thanks to Sarah Bailey for discovering and tracking down the problem.

Signed-off-by: Josh Triplett <josh@freedesktop.org>
---

I intentionally didn't change the error message "not an ethernet device".  For
the purposes of pktgen, loopback devices act like ethernet devices.

 net/core/pktgen.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 74a9a32..6fc6f9d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1930,7 +1930,7 @@ static struct net_device *pktgen_setup_dev(struct pktgen_dev *pkt_dev)
 		printk("pktgen: no such netdevice: \"%s\"\n", pkt_dev->ifname);
 		goto out;
 	}
-	if (odev->type != ARPHRD_ETHER) {
+	if (odev->type != ARPHRD_LOOPBACK && odev->type != ARPHRD_ETHER) {
 		printk("pktgen: not an ethernet device: \"%s\"\n",
 		       pkt_dev->ifname);
 		goto out_put;
-- 
1.5.0.2
