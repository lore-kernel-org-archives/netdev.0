From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] [NET] One NET_INC_STATS() could be NET_INC_STATS_BH in tcp_v4_err()
Date: Thu, 19 Oct 2006 17:45:26 +0200
Message-ID: <200610191745.26514.dada1@cosmosbay.com>
References: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu> <200610180938.39175.dada1@cosmosbay.com> <200610191257.42549.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_W25NFl4hoaOlciP"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:39894 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1946127AbWJSPp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 11:45:26 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <200610191257.42549.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_W25NFl4hoaOlciP
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I believe this NET_INC_STATS() call can be replaced by  NET_INC_STATS_BH(), a 
little bit cheaper.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_W25NFl4hoaOlciP
Content-Type: text/plain;
  charset="utf-8";
  name="OUTOFWINDOWICMPS.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="OUTOFWINDOWICMPS.patch"

--- linux/net/ipv4/tcp_ipv4.c.orig	2006-10-19 17:37:22.000000000 +0200
+++ linux-ed/net/ipv4/tcp_ipv4.c	2006-10-19 17:37:43.000000000 +0200
@@ -373,7 +373,7 @@
 	seq = ntohl(th->seq);
 	if (sk->sk_state != TCP_LISTEN &&
 	    !between(seq, tp->snd_una, tp->snd_nxt)) {
-		NET_INC_STATS(LINUX_MIB_OUTOFWINDOWICMPS);
+		NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
 		goto out;
 	}
 

--Boundary-00=_W25NFl4hoaOlciP--
