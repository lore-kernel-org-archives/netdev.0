From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [KJ] [PATCH 4/28] net/cosa: replace schedule_timeout() with msleep()
Date: Thu, 6 Jan 2005 15:41:34 -0800
Message-ID: <20050106234134.GE3055@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============57325354718019539=="
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: kernel-janitors@lists.osdl.org
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============57325354718019539==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Description: Use msleep() instead of schedule_timeout() to guarantee the task
delays as expected. Also uses the set_current_state() macro instead of direct
assignment in a pair of spots. I am still concerned about those sleeps, as
TASK_INTERRUPTIBLE() is used without any checking for signals. Hence I used
msleep() for the longer delay. Perhaps the 30 jiffy delay has not been
updated for the larger HZ values and thus could be changed to msleep(300).

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>


--- 2.6.10-v/drivers/net/wan/cosa.c	2004-12-24 13:33:49.000000000 -0800
+++ 2.6.10/drivers/net/wan/cosa.c	2005-01-04 14:57:49.000000000 -0800
@@ -543,7 +543,7 @@ static int cosa_probe(int base, int irq,
 		 * FIXME: When this code is not used as module, we should
 		 * probably call udelay() instead of the interruptible sleep.
 		 */
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		cosa_putstatus(cosa, SR_TX_INT_ENA);
 		schedule_timeout(30);
 		irq = probe_irq_off(irqs);
@@ -1564,8 +1564,7 @@ static int cosa_reset_and_read_id(struct
 	cosa_getdata8(cosa);
 	cosa_putstatus(cosa, SR_RST);
 #ifdef MODULE
-	current->state = TASK_INTERRUPTIBLE;
-	schedule_timeout(HZ/2);
+	msleep(500);
 #else
 	udelay(5*100000);
 #endif
@@ -1618,7 +1617,7 @@ static int get_wait_data(struct cosa_dat
 			return r;
 		}
 		/* sleep if not ready to read */
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(1);
 	}
 	printk(KERN_INFO "cosa: timeout in get_wait_data (status 0x%x)\n",

--===============57325354718019539==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============57325354718019539==--
