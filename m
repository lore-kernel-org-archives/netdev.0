From: domen@coderock.org
Subject: [patch 3/3] net/lanstreamer: replace schedule_timeout() with ssleep()/msleep_interruptible()
Date: Fri, 21 Jan 2005 22:03:43 +0100
Message-ID: <20050121210343.DC2E81F2D2@trashy.coderock.org>
Cc: domen@coderock.org, nacc@us.ibm.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use ssleep() / msleep_interruptible() [as appropriate]
instead of schedule_timeout() to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/tokenring/lanstreamer.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff -puN drivers/net/tokenring/lanstreamer.c~ssleep+msleep_interruptible-drivers_net_tokenring_lanstreamer drivers/net/tokenring/lanstreamer.c
--- kj/drivers/net/tokenring/lanstreamer.c~ssleep+msleep_interruptible-drivers_net_tokenring_lanstreamer	2005-01-10 18:00:21.000000000 +0100
+++ kj-domen/drivers/net/tokenring/lanstreamer.c	2005-01-10 18:00:21.000000000 +0100
@@ -454,8 +454,7 @@ static int streamer_reset(struct net_dev
 	writew(readw(streamer_mmio + BCTL) | BCTL_SOFTRESET, streamer_mmio + BCTL);
 	t = jiffies;
 	/* Hold soft reset bit for a while */
-	current->state = TASK_UNINTERRUPTIBLE;
-	schedule_timeout(HZ);
+	ssleep(1);
 	
 	writew(readw(streamer_mmio + BCTL) & ~BCTL_SOFTRESET,
 	       streamer_mmio + BCTL);
@@ -511,8 +510,7 @@ static int streamer_reset(struct net_dev
 	writew(SISR_MI, streamer_mmio + SISR_MASK_SUM);
 
 	while (!((readw(streamer_mmio + SISR)) & SISR_SRB_REPLY)) {
-		current->state = TASK_INTERRUPTIBLE;
-		schedule_timeout(HZ/10);
+		msleep_interruptible(100);
 		if (jiffies - t > 40 * HZ) {
 			printk(KERN_ERR
 			       "IBM PCI tokenring card not responding\n");
_
