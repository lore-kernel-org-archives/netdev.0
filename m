From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 04/12] iptunnel: use ll_name_to_index() for physical interface lookup
Date: Fri, 13 Nov 2015 18:08:57 +0100
Message-ID: <1447434545-32182-5-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:40702 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933381AbbKMRJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:10 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although the cache is only initialized in do_show(), this way it is at
least consistent with ip6tunnel.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iptunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 803bb83..a547852 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -226,7 +226,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 	}
 
 	if (medium[0]) {
-		p->link = if_nametoindex(medium);
+		p->link = ll_name_to_index(medium);
 		if (p->link == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", medium);
 			return -1;
-- 
2.1.2
