From: Amol Lad <amol@verismonetworks.com>
Subject: [KJ] [PATCH] drivers/net/depca.c: Replacing yield with a better
	function
Date: Mon, 09 Oct 2006 17:03:27 +0530
Message-ID: <1160393608.19143.238.camel@amol.verismonetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: netdev@vger.kernel.org, kernel Janitors <kernel-janitors@lists.osdl.org>
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

The change removes the 'manual' schedule_timeout and replaces it with
schedule_timeout_uninterruptible

Tested compile only with allmodconfig

Signed-off-by: Amol Lad <amol@verismonetworks.com>
---
 depca.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)
---
--- linux-2.6.19-rc1-orig/drivers/net/depca.c	2006-10-05 14:00:47.000000000=
 +0530
+++ linux-2.6.19-rc1/drivers/net/depca.c	2006-10-09 16:37:13.000000000 +0530
@@ -738,7 +738,7 @@ static int __init depca_hw_init (struct =

 	   interrupts. For now we will always get a DMA error. */
 	if (dev->irq < 2) {
 		unsigned char irqnum;
-		unsigned long irq_mask, delay;
+		unsigned long irq_mask;
 =

 		irq_mask =3D probe_irq_on();
 =

@@ -767,9 +767,7 @@ static int __init depca_hw_init (struct =

 		/* Trigger an initialization just for the interrupt. */
 		outw(INEA | INIT, DEPCA_DATA);
 =

-		delay =3D jiffies + HZ/50;
-		while (time_before(jiffies, delay))
-			yield();
+		schedule_timeout_uninterruptible(jiffies + HZ/50);
 =

 		irqnum =3D probe_irq_off(irq_mask);
 =
