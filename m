From: Christoph Schulz <develop@kristov.de>
Subject: [PATCH iproute2 v2] ip: allow using a device "help" (or a prefix
 thereof)
Date: Fri, 25 Sep 2015 08:44:07 +0200
Message-ID: <5604ED37.4020103@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Wilhelm Wijkander <lists@0x5e.se>,
	Vadim Kochan <vadim4j@gmail.com>,
	Leonhard Preis <leonhard@pre.is>
To: netdev@vger.kernel.org, lists@0x5e.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1137-han.de-nserver.de ([77.75.249.171]:18412 "EHLO
	server1137-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752015AbbIYGog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 02:44:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device names that match "help" or a prefix thereof should be allowed anywhere
a device name can be used. Note that a suitable keyword ("dev" or "name", the
latter for "ip tunnel") has to be used in these cases to resolve ambiguities.

Signed-off-by: Christoph Schulz <develop@kristov.de>
Reported-by: Leonhard Preis <leonhard@pre.is>
Reported-by: Wilhelm Wijkander <lists@0x5e.se>
---
 ip/ip6tunnel.c | 2 +-
 ip/ipaddress.c | 2 +-
 ip/iplink.c    | 3 +--
 ip/ipmaddr.c   | 2 +-
 4 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 62a8240..9884efd 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -287,7 +287,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 			if (strcmp(*argv, "name") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			if (p->name[0])
 				duparg2("name", *argv);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index e539847..e864ca6 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1580,7 +1580,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			if (filter_dev)
 				duparg2("dev", *argv);
diff --git a/ip/iplink.c b/ip/iplink.c
index 1c45205..f30de86 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -1148,8 +1148,7 @@ static int do_set(int argc, char **argv)
 		} else {
 			if (strcmp(*argv, "dev") == 0)
 				NEXT_ARG();
-
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 
 			if (dev)
diff --git a/ip/ipmaddr.c b/ip/ipmaddr.c
index a77a18f..cbd6d11 100644
--- a/ip/ipmaddr.c
+++ b/ip/ipmaddr.c
@@ -257,7 +257,7 @@ static int multiaddr_list(int argc, char **argv)
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
+			else if (matches(*argv, "help") == 0)
 				usage();
 			if (filter.dev)
 				duparg2("dev", *argv);
-- 
2.4.6
