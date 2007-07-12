From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] tcp: tcp probe add back ssthresh field
Date: Thu, 12 Jul 2007 12:45:11 -0700
Message-ID: <20070712124511.56f7cc3a@freepuppy.rosehill.hemminger.net>
References: <20070711105115.43ae0530@freepuppy.rosehill.hemminger.net>
	<20070711.194402.32095330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50279 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754670AbXGLTpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 15:45:49 -0400
In-Reply-To: <20070711.194402.32095330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sangtae noticed the ssthresh got missed.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/ipv4/tcp_probe.c	2007-07-11 10:47:22.000000000 -0700
+++ b/net/ipv4/tcp_probe.c	2007-07-11 14:24:12.000000000 -0700
@@ -111,6 +111,7 @@ static int jtcp_rcv_established(struct s
 			p->snd_una = tp->snd_una;
 			p->snd_cwnd = tp->snd_cwnd;
 			p->snd_wnd = tp->snd_wnd;
+			p->ssthresh = tcp_current_ssthresh(sk);
 			p->srtt = tp->srtt >> 3;
 
 			tcp_probe.head = (tcp_probe.head + 1) % bufsize;
