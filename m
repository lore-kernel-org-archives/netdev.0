From: David Miller <davem@davemloft.net>
Subject: [PATCH] rose: Fix signedness issues wrt. digi count.
Date: Mon, 20 Sep 2010 15:40:03 -0700 (PDT)
Message-ID: <20100920.154003.112580452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.j.rosenberg@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57875
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960Ab0ITWjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 18:39:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just use explicit casts, since we really can't change the
types of structures exported to userspace which have been
around for 15 years or so.

Reported-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---

The only two cases are bind() and connect().  And we only need to
guard against negative (ie. very large unsigned) values, the other
tests against addr->srose_ndigis are sane as long as we make this
check.

Committed to net-2.6

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 8e45e76..d952e7e 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -679,7 +679,7 @@ static int rose_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (addr_len == sizeof(struct sockaddr_rose) && addr->srose_ndigis > 1)
 		return -EINVAL;
 
-	if (addr->srose_ndigis > ROSE_MAX_DIGIS)
+	if ((unsigned int) addr->srose_ndigis > ROSE_MAX_DIGIS)
 		return -EINVAL;
 
 	if ((dev = rose_dev_get(&addr->srose_addr)) == NULL) {
@@ -739,7 +739,7 @@ static int rose_connect(struct socket *sock, struct sockaddr *uaddr, int addr_le
 	if (addr_len == sizeof(struct sockaddr_rose) && addr->srose_ndigis > 1)
 		return -EINVAL;
 
-	if (addr->srose_ndigis > ROSE_MAX_DIGIS)
+	if ((unsigned int) addr->srose_ndigis > ROSE_MAX_DIGIS)
 		return -EINVAL;
 
 	/* Source + Destination digis should not exceed ROSE_MAX_DIGIS */
