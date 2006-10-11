From: Amol Lad <amol@verismonetworks.com>
Subject: [KJ] [PATCH 4/4] drivers/net/sis900.c: Replacing yield() with a
	better	alternative
Date: Wed, 11 Oct 2006 18:37:38 +0530
Message-ID: <1160572058.19143.340.camel@amol.verismonetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: kernel Janitors <kernel-janitors@lists.osdl.org>
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: netdev@vger.kernel.org
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

*Please check if timeout should be increased*

Signed-off-by: Amol Lad <amol@verismonetworks.com>
---
diff -uprN -X linux-2.6.19-rc1-orig/Documentation/dontdiff linux-2.6.19-rc1=
-orig/drivers/net/wireless/hostap/hostap_hw.c linux-2.6.19-rc1/drivers/net/=
wireless/hostap/hostap_hw.c
--- linux-2.6.19-rc1-orig/drivers/net/wireless/hostap/hostap_hw.c	2006-09-2=
1 10:15:37.000000000 +0530
+++ linux-2.6.19-rc1/drivers/net/wireless/hostap/hostap_hw.c	2006-10-11 17:=
41:25.000000000 +0530
@@ -993,7 +993,7 @@ static u16 hfa384x_allocate_fid(struct n
 	delay =3D jiffies + HFA384X_ALLOC_COMPL_TIMEOUT;
 	while (!(HFA384X_INW(HFA384X_EVSTAT_OFF) & HFA384X_EV_ALLOC) &&
 	       time_before(jiffies, delay))
-		yield();
+		schedule_timeout_interruptible(1);
 	if (!(HFA384X_INW(HFA384X_EVSTAT_OFF) & HFA384X_EV_ALLOC)) {
 		printk("%s: fid allocate, len=3D%d - timeout\n", dev->name, len);
 		return 0xffff;
@@ -1333,7 +1333,7 @@ static int prism2_hw_init(struct net_dev
 	delay =3D jiffies + HFA384X_INIT_TIMEOUT;
 	while (!(HFA384X_INW(HFA384X_EVSTAT_OFF) & HFA384X_EV_CMD) &&
 	       time_before(jiffies, delay))
-		yield();
+		schedule_timeout_interruptible(1);
 	if (!(HFA384X_INW(HFA384X_EVSTAT_OFF) & HFA384X_EV_CMD)) {
 		printk(KERN_DEBUG "%s: assuming no Primary image in "
 		       "flash - card initialization not completed\n",
