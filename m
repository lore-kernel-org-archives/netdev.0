From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 1/3] e100: Replace locally implemented delay routines
 with call to msleep (nacc@us.ibm.com)
Date: Thu, 6 Jan 2005 17:01:47 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061407420.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>

diff -up net-drivers-2.6/drivers/net/e100.c net-drivers-2.6/drivers/net/e100.c.new
--- net-drivers-2.6/drivers/net/e100.c	2004-12-02 10:09:34.000000000 -0800
+++ net-drivers-2.6/drivers/net/e100.c.new	2004-12-02 10:09:36.000000000 -0800
@@ -620,8 +620,7 @@ static int e100_self_test(struct nic *ni
 	writel(selftest | dma_addr, &nic->csr->port);
 	e100_write_flush(nic);
 	/* Wait 10 msec for self-test to complete */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 100 + 1);
+	msleep(10);
 
 	/* Interrupts are enabled after self-test */
 	e100_disable_irq(nic);
@@ -669,8 +668,7 @@ static void e100_eeprom_write(struct nic
 			e100_write_flush(nic); udelay(4);
 		}
 		/* Wait 10 msec for cmd to complete */
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 100 + 1);
+		msleep(10);
 
 		/* Chip deselect */
 		writeb(0, &nic->csr->eeprom_ctrl_lo);
@@ -1759,8 +1758,7 @@ static int e100_loopback_test(struct nic
 	memset(skb->data, 0xFF, ETH_DATA_LEN);
 	e100_xmit_frame(skb, nic->netdev);
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 100 + 1);
+	msleep(10);
 
 	if(memcmp(nic->rx_to_clean->skb->data + sizeof(struct rfd),
 	   skb->data, ETH_DATA_LEN))
@@ -1846,8 +1843,7 @@ static void e100_get_regs(struct net_dev
 			mdio_read(netdev, nic->mii.phy_id, i);
 	memset(nic->mem->dump_buf, 0, sizeof(nic->mem->dump_buf));
 	e100_exec_cb(nic, NULL, e100_dump);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 100 + 1);
+	msleep(10);
 	memcpy(&buff[2 + E100_PHY_REGS], nic->mem->dump_buf,
 		sizeof(nic->mem->dump_buf));
 }
@@ -2026,8 +2022,7 @@ static int e100_phys_id(struct net_devic
 	if(!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
 		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
 	mod_timer(&nic->blink_timer, jiffies);
-	set_current_state(TASK_INTERRUPTIBLE);
-	schedule_timeout(data * HZ);
+	msleep_interruptible(data * 1000);
 	del_timer_sync(&nic->blink_timer);
 	mdio_write(netdev, nic->mii.phy_id, MII_LED_CONTROL, 0);
 
