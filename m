From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 2/3] ip/ip6tunnel: reset encap limit flag on change
Date: Wed, 14 Nov 2012 16:29:25 +0100
Message-ID: <1352906966-12932-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1352906966-12932-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34811 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932701Ab2KNP2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:28:38 -0500
In-Reply-To: <1352906966-12932-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flag IP6_TNL_F_IGN_ENCAP_LIMIT is set when encaplimit is none, but it was not
removed if encaplimit was set on update (ip tunnel change).

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ip6tunnel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index b23377a..7aaac61 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -157,6 +157,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 				if (get_u8(&uval, *argv, 0) < -1)
 					invarg("invalid ELIM", *argv);
 				p->encap_limit = uval;
+				p->flags &= ~IP6_TNL_F_IGN_ENCAP_LIMIT;
 			}
 		} else if (strcmp(*argv, "hoplimit") == 0 ||
 			   strcmp(*argv, "ttl") == 0 ||
-- 
1.7.12
