From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch iproute2] do not exit silently when link is not found
Date: Tue,  3 Jun 2014 16:06:45 -0700
Message-ID: <1401836805-26937-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:56274 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbaFCXHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 19:07:01 -0400
Received: by mail-pd0-f177.google.com with SMTP id g10so5237442pdj.36
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 16:07:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

When we create a tunnel on top of a link and the link specified
in cmdline doesn't exist, an error message should be shown.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index b9a516e..53c50ac 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -99,8 +99,11 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		} else if (!matches(*argv, "dev")) {
 			NEXT_ARG();
 			link = if_nametoindex(*argv);
-			if (link == 0)
+			if (link == 0) {
+				fprintf(stderr, "Cannot find device \"%s\"\n",
+					*argv);
 				exit(-1);
+			}
 		} else if (!matches(*argv, "ttl") ||
 			   !matches(*argv, "hoplimit")) {
 			unsigned uval;
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 9ae8847..f96ce45 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -250,8 +250,11 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 
 	if (medium[0]) {
 		p->link = if_nametoindex(medium);
-		if (p->link == 0)
+		if (p->link == 0) {
+			fprintf(stderr, "Cannot find device \"%s\"\n",
+				medium);
 			return -1;
+		}
 	}
 
 	if (p->i_key == 0 && IN_MULTICAST(ntohl(p->iph.daddr))) {
diff --git a/ip/link_gre.c b/ip/link_gre.c
index 1747886..fda84d8 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -207,8 +207,11 @@ get_failed:
 		} else if (!matches(*argv, "dev")) {
 			NEXT_ARG();
 			link = if_nametoindex(*argv);
-			if (link == 0)
+			if (link == 0) {
+				fprintf(stderr, "Cannot find device \"%s\"\n",
+					*argv);
 				exit(-1);
+			}
 		} else if (!matches(*argv, "ttl") ||
 			   !matches(*argv, "hoplimit")) {
 			unsigned uval;
diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index 4c9c536..c7183e2 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -225,8 +225,11 @@ get_failed:
 		} else if (!matches(*argv, "dev")) {
 			NEXT_ARG();
 			link = if_nametoindex(*argv);
-			if (link == 0)
+			if (link == 0) {
+				fprintf(stderr, "Cannot find device \"%s\"\n",
+					*argv);
 				exit(-1);
+			}
 		} else if (!matches(*argv, "ttl") ||
 			   !matches(*argv, "hoplimit")) {
 			__u8 uval;
diff --git a/ip/link_vti.c b/ip/link_vti.c
index 77a7482..6274c83 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -171,8 +171,11 @@ get_failed:
 		} else if (!matches(*argv, "dev")) {
 			NEXT_ARG();
 			link = if_nametoindex(*argv);
-			if (link == 0)
+			if (link == 0) {
+				fprintf(stderr, "Cannot find device \"%s\"\n",
+					*argv);
 				exit(-1);
+			}
 		} else
 			usage();
 		argc--; argv++;
