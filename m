From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 08/12] iptunnel: share common code when setting tunnel mode
Date: Fri, 13 Nov 2015 18:09:01 +0100
Message-ID: <1447434545-32182-9-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:56756 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933420AbbKMRJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:12 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iptunnel.c | 39 ++++++++++++++-------------------------
 1 file changed, 14 insertions(+), 25 deletions(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index e323c1f..92edb34 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -47,6 +47,15 @@ static void usage(void)
 	exit(-1);
 }
 
+static void set_tunnel_proto(struct ip_tunnel_parm *p, int proto)
+{
+	if (p->iph.protocol && p->iph.protocol != proto) {
+		fprintf(stderr,"You managed to ask for more than one tunnel mode.\n");
+		exit(-1);
+	}
+	p->iph.protocol = proto;
+}
+
 static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 {
 	int count = 0;
@@ -68,38 +77,18 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 			NEXT_ARG();
 			if (strcmp(*argv, "ipip") == 0 ||
 			    strcmp(*argv, "ip/ip") == 0) {
-				if (p->iph.protocol && p->iph.protocol != IPPROTO_IPIP) {
-					fprintf(stderr,"You managed to ask for more than one tunnel mode.\n");
-					exit(-1);
-				}
-				p->iph.protocol = IPPROTO_IPIP;
+				set_tunnel_proto(p, IPPROTO_IPIP);
 			} else if (strcmp(*argv, "gre") == 0 ||
 				   strcmp(*argv, "gre/ip") == 0) {
-				if (p->iph.protocol && p->iph.protocol != IPPROTO_GRE) {
-					fprintf(stderr,"You managed to ask for more than one tunnel mode.\n");
-					exit(-1);
-				}
-				p->iph.protocol = IPPROTO_GRE;
+				set_tunnel_proto(p, IPPROTO_GRE);
 			} else if (strcmp(*argv, "sit") == 0 ||
 				   strcmp(*argv, "ipv6/ip") == 0) {
-				if (p->iph.protocol && p->iph.protocol != IPPROTO_IPV6) {
-					fprintf(stderr,"You managed to ask for more than one tunnel mode.\n");
-					exit(-1);
-				}
-				p->iph.protocol = IPPROTO_IPV6;
+				set_tunnel_proto(p, IPPROTO_IPV6);
 			} else if (strcmp(*argv, "isatap") == 0) {
-				if (p->iph.protocol && p->iph.protocol != IPPROTO_IPV6) {
-					fprintf(stderr, "You managed to ask for more than one tunnel mode.\n");
-					exit(-1);
-				}
-				p->iph.protocol = IPPROTO_IPV6;
+				set_tunnel_proto(p, IPPROTO_IPV6);
 				isatap++;
 			} else if (strcmp(*argv, "vti") == 0) {
-				if (p->iph.protocol && p->iph.protocol != IPPROTO_IPIP) {
-					fprintf(stderr, "You managed to ask for more than one tunnel mode.\n");
-					exit(-1);
-				}
-				p->iph.protocol = IPPROTO_IPIP;
+				set_tunnel_proto(p, IPPROTO_IPIP);
 				p->i_flags |= VTI_ISVTI;
 			} else {
 				fprintf(stderr,"Unknown tunnel mode \"%s\"\n", *argv);
-- 
2.1.2
