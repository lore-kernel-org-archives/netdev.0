From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PLIP] Check cmd in plip_ioctl
Date: Wed, 2 Jun 2004 09:28:15 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040601232814.GA25876@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jeff:

I received a bug report that a PLIP interface was incorrectly identified
as wireless because plip_ioctl did not check what the value of cmd is
before processing the request.

This patch fixes exactly that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/net/plip.c 1.20 vs edited =====
--- 1.20/drivers/net/plip.c	2004-03-04 05:52:24 +11:00
+++ edited/drivers/net/plip.c	2004-06-02 09:21:05 +10:00
@@ -1219,6 +1219,9 @@
 	struct net_local *nl = netdev_priv(dev);
 	struct plipconf *pc = (struct plipconf *) &rq->ifr_data;
 
+	if (cmd != SIOCDEVPLIP)
+		return -EOPNOTSUPP;
+
 	switch(pc->pcmd) {
 	case PLIP_GET_TIMEOUT:
 		pc->trigger = nl->trigger;

--oyUTqETQ0mS9luUI--
