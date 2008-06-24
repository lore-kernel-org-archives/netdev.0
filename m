From: David Miller <davem@davemloft.net>
Subject: Re: pppoe: fix compiler warning
Date: Tue, 24 Jun 2008 13:35:47 -0700 (PDT)
Message-ID: <20080624.133547.14143189.davem@davemloft.net>
References: <48611A06.9070607@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55425
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752115AbYFXUfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 16:35:47 -0400
In-Reply-To: <48611A06.9070607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 24 Jun 2008 18:00:06 +0200

> pppoe: fix compiler warning
> 
> Fix warning introduced by 392fdb0 (net pppoe: Check packet length on all receive paths):
> 
> drivers/net/pppoe.c: In function 'pppoe_recvmsg':
> drivers/net/pppoe.c:945: warning: comparison of distinct pointer types lacks a cast
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Should already be fixed in net-2.6 by:

commit 2645a3c3761ac25498db2e627271016c849c68e1
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Fri Jun 20 21:58:02 2008 -0700

    pppoe: warning fix
    
    Fix warning:
    drivers/net/pppoe.c: In function 'pppoe_recvmsg':
    drivers/net/pppoe.c:945: warning: comparison of distinct pointer types lacks a cast
    because skb->len is unsigned int and total_len is size_t
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index bafb69b..fc6f4b8 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -942,7 +942,7 @@ static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
 	m->msg_namelen = 0;
 
 	if (skb) {
-		total_len = min(total_len, skb->len);
+		total_len = min_t(size_t, total_len, skb->len);
 		error = skb_copy_datagram_iovec(skb, 0, m->msg_iov, total_len);
 		if (error == 0)
 			error = total_len;
