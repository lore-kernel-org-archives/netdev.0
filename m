From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] sis900: don't use yield() (v2)
Date: Tue, 27 Apr 2004 11:28:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040427112829.7c5a260a.rddunlap@osdl.org>
References: <20040427103807.311caa42.rddunlap@osdl.org>
	<408EA079.3060604@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ollie@sis.com.tw
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <408EA079.3060604@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 27 Apr 2004 14:03:37 -0400 Jeff Garzik wrote:

| I would rather do schedule_timeout(1), as that's IMO closer to the 
| intention...


From: maximilian attems <janitor@sternwelten.at>
Subject: [Kernel-janitors] [patch] use schedule_timeout() instead of yield()
	drivers/net/sis900.c


thanks to Felipe W Damasio hint rediffed.
patch is on top of linux-2.6.6-rc2

yield() removes process from active array into expired array,
better just yield the CPU for a bit.
tested on my laptop with a sis900.


 drivers/net/sis900.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)


Index: linux-266-rc2-kj1/drivers/net/sis900.c
===================================================================
--- linux-266-rc2-kj1.orig/drivers/net/sis900.c	2004-04-03 19:36:57.000000000 -0800
+++ linux-266-rc2-kj1/drivers/net/sis900.c	2004-04-21 15:32:56.000000000 -0700
@@ -600,7 +600,8 @@ static int __init sis900_mii_probe (stru
 
 	if(status & MII_STAT_LINK){
 		while (poll_bit) {
-			yield();
+			set_current_state(TASK_UNINTERRUPTIBLE);
+			schedule_timeout(1);
 
 			poll_bit ^= (mdio_read(net_dev, sis_priv->cur_phy, MII_STATUS) & poll_bit);
 			if (time_after_eq(jiffies, timeout)) {


--
