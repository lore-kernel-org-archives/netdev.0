From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH iproute2] ip link: Do not show help if 'dev he' was specified
Date: Sun, 15 Mar 2015 11:24:10 +0100
Message-ID: <55055DCA.1090108@kristov.de>
References: <1426406515-16171-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: leonhard@pre.is
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1137-han.de-nserver.de ([85.158.180.102]:57536 "EHLO
	server1137-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751751AbbCOKYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:24:20 -0400
In-Reply-To: <1426406515-16171-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 15.03.2015 09:01, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Date: Sun, 15 Mar 2015 09:11:41 +0200
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> Reported-by: Leonhard Preis <leonhard@pre.is>
> ---
>  ip/ipaddress.c | 3 +--
>  ip/iplink.c    | 6 ++----
>  2 files changed, 3 insertions(+), 6 deletions(-)

We use a similar patch at the fli4l router project, but we also modified other files (ip6tunnel.c, ipmaddr.c, ipmroute.c, ipneigh.c, iproute.c, iprule.c). I'm afraid the patch is based on iproute2 3.11.0, but it applies to 3.17.0 (the version we currently use).

I attach the patch in the hope it will prove useful, perhaps as a base for a follow-up patch of yours.


Best regards,

Christoph Schulz

-------- %< --------

Signed-off-by: Christoph Schulz <develop@kristov.de>
---
diff -urN iproute2-3.11.0.orig/ip/ip6tunnel.c iproute2-3.11.0/ip/ip6tunnel.c
--- iproute2-3.11.0.orig/ip/ip6tunnel.c	2013-09-03 17:23:03.000000000 +0200
+++ iproute2-3.11.0/ip/ip6tunnel.c	2013-12-03 20:34:45.000000000 +0100
@@ -206,7 +206,7 @@
 			if (strcmp(*argv, "name") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			if (p->name[0])
 				duparg2("name", *argv);
diff -urN iproute2-3.11.0.orig/ip/ipaddress.c iproute2-3.11.0/ip/ipaddress.c
--- iproute2-3.11.0.orig/ip/ipaddress.c	2013-09-03 17:23:03.000000000 +0200
+++ iproute2-3.11.0/ip/ipaddress.c	2013-12-03 20:34:45.000000000 +0100
@@ -1128,7 +1128,7 @@
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			if (filter_dev)
 				duparg2("dev", *argv);
@@ -1336,7 +1336,7 @@
 			if (strcmp(*argv, "local") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			if (local_len)
 				duparg2("local", *argv);
diff -urN iproute2-3.11.0.orig/ip/iplink.c iproute2-3.11.0/ip/iplink.c
--- iproute2-3.11.0.orig/ip/iplink.c	2013-09-03 17:23:03.000000000 +0200
+++ iproute2-3.11.0/ip/iplink.c	2013-12-03 20:34:45.000000000 +0100
@@ -484,7 +484,7 @@
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			if (*dev)
 				duparg2("dev", *argv);
@@ -914,7 +914,7 @@
                         if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			if (dev)
 				duparg2("dev", *argv);
diff -urN iproute2-3.11.0.orig/ip/ipmaddr.c iproute2-3.11.0/ip/ipmaddr.c
--- iproute2-3.11.0.orig/ip/ipmaddr.c	2013-09-03 17:23:03.000000000 +0200
+++ iproute2-3.11.0/ip/ipmaddr.c	2013-12-03 20:34:45.000000000 +0100
@@ -257,7 +257,7 @@
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			if (filter.dev)
 				duparg2("dev", *argv);
@@ -298,7 +298,7 @@
 			if (matches(*argv, "address") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			if (ifr.ifr_hwaddr.sa_data[0])
 				duparg("address", *argv);
diff -urN iproute2-3.11.0.orig/ip/ipmroute.c iproute2-3.11.0/ip/ipmroute.c
--- iproute2-3.11.0.orig/ip/ipmroute.c	2013-09-03 17:23:03.000000000 +0200
+++ iproute2-3.11.0/ip/ipmroute.c	2013-12-03 20:34:45.000000000 +0100
@@ -222,7 +222,7 @@
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			get_prefix(&filter.mdst, *argv, family);
 		}
diff -urN iproute2-3.11.0.orig/ip/ipneigh.c iproute2-3.11.0/ip/ipneigh.c
--- iproute2-3.11.0.orig/ip/ipneigh.c	2013-09-03 17:23:03.000000000 +0200
+++ iproute2-3.11.0/ip/ipneigh.c	2013-12-03 20:34:45.000000000 +0100
@@ -142,7 +142,7 @@
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0) {
+			else if (matches(*argv, "help") == 0) {
 				NEXT_ARG();
 			}
 			if (dst_ok)
@@ -370,7 +370,7 @@
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			get_prefix(&filter.pfx, *argv, filter.family);
 			if (filter.family == AF_UNSPEC)
diff -urN iproute2-3.11.0.orig/ip/iproute.c iproute2-3.11.0/ip/iproute.c
--- iproute2-3.11.0.orig/ip/iproute.c	2013-09-03 17:23:03.000000000 +0200
+++ iproute2-3.11.0/ip/iproute.c	2013-12-03 20:34:45.000000000 +0100
@@ -951,10 +951,12 @@
 			NEXT_ARG();
 			d = *argv;
 		} else {
+			int has_to = 0;
 			int type;
 			inet_prefix dst;
 
 			if (strcmp(*argv, "to") == 0) {
+				has_to = 1;
 				NEXT_ARG();
 			}
 			if ((**argv < '0' || **argv > '9') &&
@@ -963,7 +965,7 @@
 				req.r.rtm_type = type;
 			}
 
-			if (matches(*argv, "help") == 0)
+			if (!has_to && matches(*argv, "help") == 0)
 				usage();
 			if (dst_ok)
 				duparg2("to", *argv);
@@ -1414,8 +1416,6 @@
 		} else if (matches(*argv, "from") == 0) {
 			inet_prefix addr;
 			NEXT_ARG();
-			if (matches(*argv, "help") == 0)
-				usage();
 			from_ok = 1;
 			get_prefix(&addr, *argv, req.r.rtm_family);
 			if (req.r.rtm_family == AF_UNSPEC)
@@ -1442,7 +1442,7 @@
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			get_prefix(&addr, *argv, req.r.rtm_family);
 			if (req.r.rtm_family == AF_UNSPEC)
diff -urN iproute2-3.11.0.orig/ip/iprule.c iproute2-3.11.0/ip/iprule.c
--- iproute2-3.11.0.orig/ip/iprule.c	2013-09-03 17:23:03.000000000 +0200
+++ iproute2-3.11.0/ip/iprule.c	2013-12-03 20:34:45.000000000 +0100
@@ -331,7 +331,7 @@
 			}
 			if (matches(*argv, "help") == 0)
 				usage();
-			else if (matches(*argv, "goto") == 0) {
+			if (matches(*argv, "goto") == 0) {
 				__u32 target;
 				type = FR_ACT_GOTO;
 				NEXT_ARG();
