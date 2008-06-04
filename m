From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][L2TP]: Fix possible WARN_ON from socket code when
 UDP socket is closed
Date: Wed, 04 Jun 2008 15:11:46 -0700 (PDT)
Message-ID: <20080604.151146.104754883.davem@davemloft.net>
References: <200806042056.m54KuiI7003060@quickie.katalix.com>
	<20080604.150835.73786340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35541
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762605AbYFDWLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 18:11:49 -0400
In-Reply-To: <20080604.150835.73786340.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 04 Jun 2008 15:08:35 -0700 (PDT)

> Applied, thanks.

James your second patch doesn't apply cleanly:

@@ -1066,7 +1100,7 @@ static int pppol2tp_xmit(struct ppp_chan
 	dst_release(skb->dst);
 	skb->dst = dst_clone(__sk_dst_get(sk_tun));
 	skb_orphan(skb);
-	skb->sk = sk_tun;
+	pppol2tp_skb_set_owner_w(skb, sk_tun);
 
 	/* Queue the packet to IP for output */
 	len = skb->len;

There is no skb_orphan() call in the current pppol2tp.c code.

Please always prepare your patches against the current tree.
