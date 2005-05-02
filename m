From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [KJ] [PATCH] net/3c505: replace schedule_timeout() with msleep()
Date: Sun, 1 May 2005 23:14:46 -0700
Message-ID: <20050502061446.GB10173@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0070249961624342383=="
Cc: netdev@oss.sgi.com, Kernel-Janitors <kernel-janitors@lists.osdl.org>
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: philb@gnu.org
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

--===============0070249961624342383==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Use msleep() instead of schedule_timeout() to guarantee the task delays
as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

--- 2.6.12-rc3/drivers/net/3c505.c	2005-04-29 11:03:04.000000000 -0700
+++ 2.6.12-rc3-dev/drivers/net/3c505.c	2005-05-01 20:52:01.000000000 -0700
@@ -1317,8 +1317,7 @@ static int __init elp_sense(struct net_d
 	if (orig_HSR & DIR) {
 		/* If HCR.DIR is up, we pull it down. HSR.DIR should follow. */
 		outb(0, dev->base_addr + PORT_CONTROL);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(30*HZ/100);
+		msleep(300);
 		if (inb_status(addr) & DIR) {
 			if (elp_debug > 0)
 				printk(notfound_msg, 2);
@@ -1327,8 +1326,7 @@ static int __init elp_sense(struct net_d
 	} else {
 		/* If HCR.DIR is down, we pull it up. HSR.DIR should follow. */
 		outb(DIR, dev->base_addr + PORT_CONTROL);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(30*HZ/100);
+		msleep(300);
 		if (!(inb_status(addr) & DIR)) {
 			if (elp_debug > 0)
 				printk(notfound_msg, 3);

--===============0070249961624342383==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============0070249961624342383==--
