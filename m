From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TG3] Initialise reset_task properly
Date: Wed, 12 Nov 2003 21:48:33 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031112104833.GA15583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jeff:

I've received a queue_work crash report due to reset_task in tg3 not being
initialised correctly.  This patch should fix it.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-source-2.5/drivers/net/tg3.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/tg3.c,v
retrieving revision 1.1.1.14
diff -u -r1.1.1.14 tg3.c
--- kernel-source-2.5/drivers/net/tg3.c	26 Oct 2003 02:10:30 -0000	1.1.1.14
+++ kernel-source-2.5/drivers/net/tg3.c	12 Nov 2003 10:45:36 -0000
@@ -7601,7 +7601,7 @@
 	spin_lock_init(&tp->lock);
 	spin_lock_init(&tp->tx_lock);
 	spin_lock_init(&tp->indirect_lock);
-	PREPARE_WORK(&tp->reset_task, tg3_reset_task, tp);
+	INIT_WORK(&tp->reset_task, tg3_reset_task, tp);
 
 	tp->regs = (unsigned long) ioremap(tg3reg_base, tg3reg_len);
 	if (tp->regs == 0UL) {

--x+6KMIRAuhnl3hBn--
