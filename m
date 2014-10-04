From: Dmitry Popov <ixaphire@qrator.net>
Subject: [PATCH iproute2] ip tunnel: fix 'ip -oneline tunnel show' for some
 GRE tunnels
Date: Sat, 4 Oct 2014 19:00:25 +0400
Message-ID: <20141004190025.d26b74dab093a455381d46fc@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:58913 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbaJDPAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 11:00:31 -0400
Received: by mail-la0-f44.google.com with SMTP id gb8so2445292lab.31
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2014 08:00:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'ip -oneline tunnel show' was not "oneline" for GRE tunnels with iseq:
# ip tun add gre_test remote 1.1.1.1 local 2.2.2.2 mode gre iseq oseq
# ip -oneline tun show gre_test | wc -l
2

The problem existed because of a typo: '\n' was printed when it shouldn't be.
Fixed.

Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
---
 ip/ip6tunnel.c | 2 +-
 ip/iptunnel.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 4b73ec6..b83534e 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -117,7 +117,7 @@ static void print_tunnel(struct ip6_tnl_parm2 *p)
 		}
 
 		if (p->i_flags&GRE_SEQ)
-			printf("%s  Drop packets out of sequence.\n", _SL_);
+			printf("%s  Drop packets out of sequence.", _SL_);
 		if (p->i_flags&GRE_CSUM)
 			printf("%s  Checksum in received packet is required.", _SL_);
 		if (p->o_flags&GRE_SEQ)
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 0844a4f..caf8a28 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -409,7 +409,7 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	}
 
 	if (p->i_flags&GRE_SEQ)
-		printf("%s  Drop packets out of sequence.\n", _SL_);
+		printf("%s  Drop packets out of sequence.", _SL_);
 	if (p->i_flags&GRE_CSUM)
 		printf("%s  Checksum in received packet is required.", _SL_);
 	if (p->o_flags&GRE_SEQ)
