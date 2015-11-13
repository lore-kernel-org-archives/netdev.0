From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 09/12] iptunnel: simplify parsing TTL, allow 'hlim' as identifier
Date: Fri, 13 Nov 2015 18:09:02 +0100
Message-ID: <1447434545-32182-10-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:35782 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933416AbbKMRJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:11 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of parsing an unsigned integer and checking boundaries, simply
parse u8. This and the added ttl alias 'hlim' provide consistency with
ip6tunnel.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iptunnel.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 92edb34..8c05f6f 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -141,14 +141,13 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 			NEXT_ARG();
 			strncpy(medium, *argv, IFNAMSIZ-1);
 		} else if (strcmp(*argv, "ttl") == 0 ||
-			   strcmp(*argv, "hoplimit") == 0) {
-			unsigned uval;
+			   strcmp(*argv, "hoplimit") == 0 ||
+			   strcmp(*argv, "hlim") == 0) {
+			__u8 uval;
 			NEXT_ARG();
 			if (strcmp(*argv, "inherit") != 0) {
-				if (get_unsigned(&uval, *argv, 0))
+				if (get_u8(&uval, *argv, 0))
 					invarg("invalid TTL\n", *argv);
-				if (uval > 255)
-					invarg("TTL must be <=255\n", *argv);
 				p->iph.ttl = uval;
 			}
 		} else if (strcmp(*argv, "tos") == 0 ||
-- 
2.1.2
