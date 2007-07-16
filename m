From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH]: Can not set the IPV6_PKTINFO option
Date: Mon, 16 Jul 2007 13:41:23 +0100
Message-ID: <200707161341.23419@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:62213 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751990AbXGPMnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 08:43:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPv6]: Can not set the IPV6_PKTINFO option

The Linux manpage of ipv6(7) mentions the IPV6_PKTINFO option (and it is defined in header
files), but there is no setsockopt support for it. Aliasing to IPV6_RECVPKTINFO fixes this,
and checking datagram_recv_ctl() in net/ipv6/datagram.c confirms that this works as 
expected from the API.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -315,6 +315,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		retv = 0;
 		break;
 
+	case IPV6_PKTINFO:
 	case IPV6_RECVPKTINFO:
 		np->rxopt.bits.rxinfo = valbool;
 		retv = 0;
@@ -928,6 +929,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->ipv6only;
 		break;
 
+	case IPV6_PKTINFO:
 	case IPV6_RECVPKTINFO:
 		val = np->rxopt.bits.rxinfo;
 		break;
