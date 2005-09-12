From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 1/5] 3c59x: correct rx_dropped counting
Date: Mon, 12 Sep 2005 10:48:59 -0400
Message-ID: <09122005104859.389@bilbo.tuxdriver.com>
References: <09122005104858.332@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751370AbVILPCT@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104858.332@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only increment rx_dropped in case of lack of resources (i.e. not for
frames with errors).

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/3c59x.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2598,8 +2598,8 @@ static int vortex_rx(struct net_device *
 			} else if (vortex_debug > 0)
 				printk(KERN_NOTICE "%s: No memory to allocate a sk_buff of "
 					   "size %d.\n", dev->name, pkt_len);
+			vp->stats.rx_dropped++;
 		}
-		vp->stats.rx_dropped++;
 		issue_and_wait(dev, RxDiscard);
 	}
 
