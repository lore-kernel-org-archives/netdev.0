From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 03/12] ip{,6}tunnel: unify behaviour if physical device is not found
Date: Fri, 13 Nov 2015 18:08:56 +0100
Message-ID: <1447434545-32182-4-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:46777 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933402AbbKMRJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:09 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make ip6tunnel print an error message as well. While there, get rid of
unnecessary line breaking.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ip6tunnel.c | 4 +++-
 ip/iptunnel.c  | 3 +--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 8b842b6..410276f 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -278,8 +278,10 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 	}
 	if (medium[0]) {
 		p->link = ll_name_to_index(medium);
-		if (p->link == 0)
+		if (p->link == 0) {
+			fprintf(stderr, "Cannot find device \"%s\"\n", medium);
 			return -1;
+		}
 	}
 	return 0;
 }
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 9c9dc54..803bb83 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -228,8 +228,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 	if (medium[0]) {
 		p->link = if_nametoindex(medium);
 		if (p->link == 0) {
-			fprintf(stderr, "Cannot find device \"%s\"\n",
-				medium);
+			fprintf(stderr, "Cannot find device \"%s\"\n", medium);
 			return -1;
 		}
 	}
-- 
2.1.2
