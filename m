From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2 of 5][ATM]: [he] reorder add_wait_queue() and set_current_state()
Date: Wed, 26 Jan 2005 11:57:10 -0500
Message-ID: <200501261657.j0QGv9tT018855@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/24 13:27:20-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [he] reorder add_wait_queue() and set_current_state()
#   
#     Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/he.c
#   2005/01/24 13:27:02-05:00 chas@relax.cmf.nrl.navy.mil +2 -2
#   [ATM]: [he] reorder add_wait_queue() and set_current_state()
#   
#     Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	2005-01-25 09:37:30 -05:00
+++ b/drivers/atm/he.c	2005-01-25 09:37:30 -05:00
@@ -2575,8 +2575,8 @@
 			udelay(250);
 		}
 
-		add_wait_queue(&he_vcc->rx_waitq, &wait);
 		set_current_state(TASK_UNINTERRUPTIBLE);
+		add_wait_queue(&he_vcc->rx_waitq, &wait);
 
 		he_writel_rsr0(he_dev, RSR0_CLOSE_CONN, cid);
 		(void) he_readl_rsr0(he_dev, cid);		/* flush posted writes */
@@ -2650,8 +2650,8 @@
 		tpd->vcc = vcc;
 		wmb();
 
-		add_wait_queue(&he_vcc->tx_waitq, &wait);
 		set_current_state(TASK_UNINTERRUPTIBLE);
+		add_wait_queue(&he_vcc->tx_waitq, &wait);
 		__enqueue_tpd(he_dev, tpd, cid);
 		spin_unlock_irqrestore(&he_dev->global_lock, flags);
 
