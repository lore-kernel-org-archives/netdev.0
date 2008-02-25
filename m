From: Jim Westfall <jwestfall@surrealistic.net>
Subject: [PATCH] llc: dont trust payload size on test cmd
Date: Mon, 25 Feb 2008 08:14:39 -0800
Message-ID: <20080225161439.GZ84358@surrealistic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from snapper.surrealistic.net ([67.40.222.186]:59125 "EHLO
	snapper.surrealistic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222AbYBYQOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 11:14:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

In testing its not safe to trust the payload length we are given in a
received llc test command header.  Instead we should calculate this 
ourselves or run the risk of an skb_over_panic() if the received length in 
the header is > then the actual payload size.

Signed-off-by: Jim Westfall <jwestfall@surrealistic.net>

diff -urp linux-2.6.24.2.org/include/net/llc_pdu.h linux-2.6.24.2/include/net/llc_pdu.h
--- linux-2.6.24.2.org/include/net/llc_pdu.h	2008-02-10 21:51:11.000000000 -0800
+++ linux-2.6.24.2/include/net/llc_pdu.h	2008-02-24 10:23:02.000000000 -0800
@@ -348,7 +348,7 @@ static inline void llc_pdu_init_as_test_
 		struct llc_pdu_un *ev_pdu = llc_pdu_un_hdr(ev_skb);
 		int dsize;
 
-		dsize = ntohs(eth_hdr(ev_skb)->h_proto) - 3;
+		dsize = (ev_skb->tail - (u8 *)ev_pdu) - 3;
 		memcpy(((u8 *)pdu) + 3, ((u8 *)ev_pdu) + 3, dsize);
 		skb_put(skb, dsize);
 	}

----- End forwarded message -----
