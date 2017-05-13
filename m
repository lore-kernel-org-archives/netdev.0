From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 1/2] bpf: update printing of generic xdp mode
Date: Sat, 13 May 2017 02:32:34 +0200
Message-ID: <3c90a0b9480c61746220636ed48320da53410b6f.1494635217.git.daniel@iogearbox.net>
References: <cover.1494635217.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42830 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756965AbdEMAcs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 20:32:48 -0400
In-Reply-To: <cover.1494635217.git.daniel@iogearbox.net>
In-Reply-To: <cover.1494635217.git.daniel@iogearbox.net>
References: <cover.1494635217.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up to d67b9cd28c1d ("xdp: refine xdp api with regards to
generic xdp") in order to update the XDP dumping part.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ip/iplink_xdp.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
index a1380ee..98503fa 100644
--- a/ip/iplink_xdp.c
+++ b/ip/iplink_xdp.c
@@ -79,17 +79,20 @@ int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic)
 void xdp_dump(FILE *fp, struct rtattr *xdp)
 {
 	struct rtattr *tb[IFLA_XDP_MAX + 1];
-	__u32 flags = 0;
+	__u8 mode;
 
 	parse_rtattr_nested(tb, IFLA_XDP_MAX, xdp);
 
-	if (!tb[IFLA_XDP_ATTACHED] ||
-	    !rta_getattr_u8(tb[IFLA_XDP_ATTACHED]))
+	if (!tb[IFLA_XDP_ATTACHED])
 		return;
 
-	if (tb[IFLA_XDP_FLAGS])
-		flags = rta_getattr_u32(tb[IFLA_XDP_FLAGS]);
-
-	fprintf(fp, "xdp%s ",
-		flags & XDP_FLAGS_SKB_MODE ? "generic" : "");
+	mode = rta_getattr_u8(tb[IFLA_XDP_ATTACHED]);
+	if (mode == XDP_ATTACHED_NONE)
+		return;
+	else if (mode == XDP_ATTACHED_DRV)
+		fprintf(fp, "xdp ");
+	else if (mode == XDP_ATTACHED_SKB)
+		fprintf(fp, "xdpgeneric ");
+	else
+		fprintf(fp, "xdp[%u] ", mode);
 }
-- 
1.9.3
