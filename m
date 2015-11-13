From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 11/12] iptunnel: sanitize copying tunnel name
Date: Fri, 13 Nov 2015 18:09:04 +0100
Message-ID: <1447434545-32182-12-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39203 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933424AbbKMRJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:11 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since p->name is only IFNAMSIZ bytes, do not copy more than IFNAMSIZ - 1
bytes into it so there remains at least a single null byte in the end.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iptunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 3b46a15..b377a5b 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -175,7 +175,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				usage();
 			if (p->name[0])
 				duparg2("name", *argv);
-			strncpy(p->name, *argv, IFNAMSIZ);
+			strncpy(p->name, *argv, IFNAMSIZ - 1);
 			if (cmd == SIOCCHGTUNNEL && count == 0) {
 				struct ip_tunnel_parm old_p;
 				memset(&old_p, 0, sizeof(old_p));
-- 
2.1.2
