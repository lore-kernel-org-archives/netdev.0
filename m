From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] IPV6 : segmentation offload not set correctly on TCP
 children
Date: Fri, 25 Aug 2006 15:43:53 -0700
Message-ID: <20060825154353.3ecaf508@localhost.localdomain>
References: <20060821212243.GA1558@cip.informatik.uni-erlangen.de>
	<20060821150231.31a947d4@localhost.localdomain>
	<20060821222634.GC21790@cip.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:452 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751545AbWHYWoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 18:44:18 -0400
To: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060821222634.GC21790@cip.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TCP over IPV6 would incorrectly inherit the GSO settings.
This would cause kernel to send Tcp Segmentation Offload packets for
IPV6 data to devices that can't handle it. It caused the sky2 driver
to lock http://bugzilla.kernel.org/show_bug.cgi?id=7050
and the e1000 would generate bogus packets. I can't blame the
hardware for gagging if the upper layers feed it garbage.

This was a new bug in 2.6.18 introduced with GSO support.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- linux-2.6.orig/net/ipv6/tcp_ipv6.c	2006-08-03 09:09:16.000000000 -0700
+++ linux-2.6/net/ipv6/tcp_ipv6.c	2006-08-25 15:30:31.000000000 -0700
@@ -944,7 +944,7 @@
 	 * comment in that function for the gory details. -acme
 	 */
 
-	sk->sk_gso_type = SKB_GSO_TCPV6;
+	newsk->sk_gso_type = SKB_GSO_TCPV6;
 	__ip6_dst_store(newsk, dst, NULL);
 
 	newtcp6sk = (struct tcp6_sock *)newsk;
