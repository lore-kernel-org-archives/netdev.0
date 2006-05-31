From: Amnon Aaronsohn <bla@cs.huji.ac.il>
Subject: [PATCH] don't automatically drop packets from 0.0.0.0/8
Date: Wed, 31 May 2006 20:07:34 +0300 (IDT)
Message-ID: <Pine.LNX.4.56.0605311958070.8718@duke.cs.huji.ac.il>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs1.cs.huji.ac.il ([132.65.16.10]:34571 "EHLO cs1.cs.huji.ac.il")
	by vger.kernel.org with ESMTP id S1751156AbWEaRHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 13:07:36 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For some reason linux drops all incoming packets which have a source
address in the 0.0.0.0/8 range, although these are valid addresses. The
attached patch fixes this. (It still drops packets coming from 0.0.0.0
since that's a special address.)

Signed-off-by: Amnon Aaronsohn <bla@cs.huji.ac.il>
---

--- linux-2.6.16.18/net/ipv4/route.c.old	2006-05-30 08:57:42.000000000 +0300
+++ linux-2.6.16.18/net/ipv4/route.c	2006-05-30 08:58:22.000000000 +0300
@@ -1935,7 +1935,7 @@ static int ip_route_input_slow(struct sk
 	/* Accept zero addresses only to limited broadcast;
 	 * I even do not know to fix it or not. Waiting for complains :-)
 	 */
-	if (ZERONET(saddr))
+	if (saddr == 0)
 		goto martian_source;

 	if (BADCLASS(daddr) || ZERONET(daddr) || LOOPBACK(daddr))
