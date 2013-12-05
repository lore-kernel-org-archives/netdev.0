From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2] iptunnel: Allow GRE_KEY for vti interface
Date: Fri,  6 Dec 2013 00:19:01 +0800
Message-ID: <1386260341-9103-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Hangbin Liu <liuhangbin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:37845 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756901Ab3LEQTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 11:19:16 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so26222902pbb.32
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 08:19:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vti interface will use GRE_KEY to match the right policy in kernel. So we
can not return fail when the tunnel is vti.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iptunnel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 40186d3..950f984 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -240,8 +240,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 		}
 	}
 
-	if (p->iph.protocol == IPPROTO_IPIP || p->iph.protocol == IPPROTO_IPV6) {
-		if ((p->i_flags & GRE_KEY) || (p->o_flags & GRE_KEY)) {
+	if ((p->i_flags & GRE_KEY) || (p->o_flags & GRE_KEY)) {
+		if (!(p->i_flags & VTI_ISVTI) && (p->iph.protocol != IPPROTO_GRE)) {
 			fprintf(stderr, "Keys are not allowed with ipip and sit tunnels\n");
 			return -1;
 		}
-- 
1.8.1.4
