From: Jan Engelhardt <jengelh@medozas.de>
Subject: iproute2: prints bogus hoplimit
Date: Tue, 24 Feb 2009 11:27:52 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902241125020.329@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:60770 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbZBXK14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 05:27:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


$ ip -6 r
fc00::/7 dev rtl0  proto kernel  metric 256  mtu 1500 advmss 1440 
hoplimit 4294967295

Most likely, "hoplimit -1" would be the right number, though I am not 
sure if simply changing %u by %d is a correct thing to do, since it 
would affect all fields.

---
 ip/iproute.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 6a2ea05..91a8cc0 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -507,7 +507,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 			if (i != RTAX_RTT && i != RTAX_RTTVAR &&
 			    i != RTAX_RTO_MIN)
-				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
+				fprintf(fp, " %d", *(unsigned*)RTA_DATA(mxrta[i]));
 			else {
 				unsigned long long val = *(unsigned*)RTA_DATA(mxrta[i]);
 
-- 
