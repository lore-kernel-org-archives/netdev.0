From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TG3] Initialise reset_task properly
Date: Wed, 12 Nov 2003 21:49:28 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031112104928.GA15629@gondor.apana.org.au>
References: <20031112104833.GA15583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OXfL5xGRrasGEqWY"
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031112104833.GA15583@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Nov 12, 2003 at 09:48:33PM +1100, herbert wrote:
> 
> I've received a queue_work crash report due to reset_task in tg3 not being
> initialised correctly.  This patch should fix it.

And here is the 2.4 version.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=q

Index: kernel-source-2.4/drivers/net/tg3.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.4/drivers/net/tg3.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 tg3.c
--- kernel-source-2.4/drivers/net/tg3.c	30 Aug 2003 06:01:39 -0000	1.1.1.4
+++ kernel-source-2.4/drivers/net/tg3.c	12 Nov 2003 10:46:11 -0000
@@ -6714,7 +6714,7 @@
 	spin_lock_init(&tp->lock);
 	spin_lock_init(&tp->tx_lock);
 	spin_lock_init(&tp->indirect_lock);
-	PREPARE_TQUEUE(&tp->reset_task, tg3_reset_task, tp);
+	INIT_TQUEUE(&tp->reset_task, tg3_reset_task, tp);
 
 	tp->regs = (unsigned long) ioremap(tg3reg_base, tg3reg_len);
 	if (tp->regs == 0UL) {

--OXfL5xGRrasGEqWY--
