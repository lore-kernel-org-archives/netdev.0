From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 3/3] ip/ip6tunnel: fix update of tclass and flowlabel
Date: Wed, 14 Nov 2012 16:29:26 +0100
Message-ID: <1352906966-12932-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1352906966-12932-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34810 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932713Ab2KNP2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:28:38 -0500
In-Reply-To: <1352906966-12932-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tclass or flowlabel field were updated, we only performed an OR with the
new value. For example, it was not possible to reset tclass:
  ip -6 tunnel change ip6tnl2 tclass 0

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ip6tunnel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 7aaac61..fcc9f33 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -173,6 +173,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 			   matches(*argv, "dsfield") == 0) {
 			__u8 uval;
 			NEXT_ARG();
+			p->flowinfo &= ~IP6_FLOWINFO_TCLASS;
 			if (strcmp(*argv, "inherit") == 0)
 				p->flags |= IP6_TNL_F_USE_ORIG_TCLASS;
 			else {
@@ -185,6 +186,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 			   strcmp(*argv, "fl") == 0) {
 			__u32 uval;
 			NEXT_ARG();
+			p->flowinfo &= ~IP6_FLOWINFO_FLOWLABEL;
 			if (strcmp(*argv, "inherit") == 0)
 				p->flags |= IP6_TNL_F_USE_ORIG_FLOWLABEL;
 			else {
-- 
1.7.12
