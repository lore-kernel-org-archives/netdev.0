From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linux-2.6.7 Equalizer Load-balancer.  eql.c. local non-privileged DoS
Date: Fri, 18 Jun 2004 21:35:42 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <E1BbHeo-00053Z-00@gondolin.me.apana.org.au>
References: <20040618115153.3ad2dc32.vitalyvb@ukr.net>
Cc: linux-kernel@vger.kernel.org, alan@redhat.com, davem@redhat.com,
	jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265117AbUFRLgc@vger.kernel.org>
To: vitalyvb@ukr.net (Vitaly V. Bursov)
In-Reply-To: <20040618115153.3ad2dc32.vitalyvb@ukr.net>
List-Id: netdev.vger.kernel.org

Vitaly V. Bursov <vitalyvb@ukr.net> wrote:
> 
> there are multiple vulns in drivers/net/eql.c
> 
> if there is no such device, dev_get_by_name returns NULL and everything dies.
> Exploiting this is trivial.

Thanks for the report.  This patch should fix them.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== drivers/net/eql.c 1.13 vs edited =====
--- 1.13/drivers/net/eql.c	2004-06-05 01:50:36 +10:00
+++ edited/drivers/net/eql.c	2004-06-18 21:30:49 +10:00
@@ -497,6 +497,8 @@
 	slave_dev = dev_get_by_name(sc.slave_name);
 
 	ret = -EINVAL;
+	if (!slave_dev)
+		return ret;
 
 	spin_lock_bh(&eql->queue.lock);
 	if (eql_is_slave(slave_dev)) {
@@ -531,6 +533,8 @@
 	slave_dev = dev_get_by_name(sc.slave_name);
 
 	ret = -EINVAL;
+	if (!slave_dev)
+		return ret;
 
 	spin_lock_bh(&eql->queue.lock);
 	if (eql_is_slave(slave_dev)) {
