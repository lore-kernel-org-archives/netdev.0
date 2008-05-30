From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] tcp: Increment OUTRSTS in tcp_send_active_reset()
Date: Fri, 30 May 2008 10:02:27 -0700
Message-ID: <1212166947.12643.8.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:49871 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503AbYE3RCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 13:02:51 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4UH2eVX024634
	for <netdev@vger.kernel.org>; Fri, 30 May 2008 13:02:40 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4UH2TZa141568
	for <netdev@vger.kernel.org>; Fri, 30 May 2008 13:02:30 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4UH2TSt015087
	for <netdev@vger.kernel.org>; Fri, 30 May 2008 13:02:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP "resets sent" counter is not incremented when a TCP Reset is 
sent via tcp_send_active_reset().

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e399bde..23c22d4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2131,6 +2131,8 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	if (tcp_transmit_skb(sk, skb, 0, priority))
 		NET_INC_STATS(LINUX_MIB_TCPABORTFAILED);
+ 
+	TCP_INC_STATS(TCP_MIB_OUTRSTS);
 }
 
 /* WARNING: This routine must only be called when we have already sent


