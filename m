From: janitor@sternwelten.at
Subject: [patch 05/16]  net/e100: replace schedule_timeout() with 	msleep()
Date: Wed, 01 Sep 2004 23:02:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cFv-0007nx-Fp@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list. This is one (of
many) cases where I made a decision about replacing

set_current_state(TASK_INTERRUPTIBLE);
schedule_timeout(some_time);

with

msleep(jiffies_to_msecs(some_time));

msleep() is not exactly the same as the previous code, but I only did
this replacement where I thought long delays were *desired*. If this is
not the case here, then just disregard this patch. 

Thanks,
Nish



Description: Replace schedule_timeout() with msleep() to guarantee the
task delays for the desired time.

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>




---

 linux-2.6.9-rc1-bk7-max/drivers/net/e100.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff -puN drivers/net/e100.c~msleep-drivers_net_e100 drivers/net/e100.c
--- linux-2.6.9-rc1-bk7/drivers/net/e100.c~msleep-drivers_net_e100	2004-09-01 19:35:28.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/e100.c	2004-09-01 19:35:28.000000000 +0200
@@ -623,8 +623,7 @@ static int e100_self_test(struct nic *ni
 	writel(selftest | dma_addr, &nic->csr->port);
 	e100_write_flush(nic);
 	/* Wait 10 msec for self-test to complete */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 100 + 1);
+	msleep(10);
 
 	/* Interrupts are enabled after self-test */
 	e100_disable_irq(nic);
@@ -672,8 +671,7 @@ static void e100_eeprom_write(struct nic
 			e100_write_flush(nic); udelay(4);
 		}
 		/* Wait 10 msec for cmd to complete */
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 100 + 1);
+		msleep(10);
 
 		/* Chip deselect */
 		writeb(0, &nic->csr->eeprom_ctrl_lo);
@@ -1758,8 +1756,7 @@ static int e100_loopback_test(struct nic
 	memset(skb->data, 0xFF, ETH_DATA_LEN);
 	e100_xmit_frame(skb, nic->netdev);
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 100 + 1);
+	msleep(10);
 
 	if(memcmp(nic->rx_to_clean->skb->data + sizeof(struct rfd),
 	   skb->data, ETH_DATA_LEN))
@@ -1845,8 +1842,7 @@ static void e100_get_regs(struct net_dev
 			mdio_read(netdev, nic->mii.phy_id, i);
 	memset(nic->mem->dump_buf, 0, sizeof(nic->mem->dump_buf));
 	e100_exec_cb(nic, NULL, e100_dump);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 100 + 1);
+	msleep(10);
 	memcpy(&buff[2 + E100_PHY_REGS], nic->mem->dump_buf,
 		sizeof(nic->mem->dump_buf));
 }
@@ -2020,8 +2016,7 @@ static int e100_phys_id(struct net_devic
 	if(!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
 		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
 	mod_timer(&nic->blink_timer, jiffies);
-	set_current_state(TASK_INTERRUPTIBLE);
-	schedule_timeout(data * HZ);
+	msleep(data * 1000);
 	del_timer_sync(&nic->blink_timer);
 	mdio_write(netdev, nic->mii.phy_id, MII_LED_CONTROL, 0);
 

_
