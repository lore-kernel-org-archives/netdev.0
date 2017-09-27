From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mkiss: remove redundant check on len being zero
Date: Wed, 27 Sep 2017 22:45:13 +0100
Message-ID: <20170927214513.22562-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The check on len is redundant as it is always greater than 1,
so just remove it and make the printk less complex.

Detected by CoverityScan, CID#1226729 ("Logically dead code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/hamradio/mkiss.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index aec6c26563cf..54bf8e6e4a09 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -477,7 +477,8 @@ static void ax_encaps(struct net_device *dev, unsigned char *icp, int len)
 				  cmd = 0;
 				}
 				ax->crcauto = (cmd ? 0 : 1);
-				printk(KERN_INFO "mkiss: %s: crc mode %s %d\n", ax->dev->name, (len) ? "set to" : "is", cmd);
+				printk(KERN_INFO "mkiss: %s: crc mode set to %d\n",
+				       ax->dev->name, cmd);
 			}
 			spin_unlock_bh(&ax->buflock);
 			netif_start_queue(dev);
-- 
2.14.1
