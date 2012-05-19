From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: man page and /bin/ip disagree on del vs delete
Date: Sat, 19 May 2012 16:08:21 +0200
Message-ID: <20120519140821.GA5400@amd64.fatal.se>
References: <20120518012928.26883.11644.reportbug@linear.rut.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Henney <robh@rut.org>, 673355@bugs.debian.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b11.telenor.se ([62.127.194.20]:51707 "EHLO
	smtprelay-b11.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757156Ab2ESOFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 10:05:50 -0400
Received: from ipb5.telenor.se (ipb5.telenor.se [195.54.127.168])
	by smtprelay-b11.telenor.se (Postfix) with ESMTP id 39133CEC6
	for <netdev@vger.kernel.org>; Sat, 19 May 2012 16:05:47 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20120518012928.26883.11644.reportbug@linear.rut.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 09:29:28PM -0400, Robert Henney wrote:
> the 'ip' man page does not mention the command "del" at all but does
> claim, "As a rule, it is possible to add, delete and show (or list ) objects".  
> however, 'ip' does not always recognize "delete" as a commend.
> 
> robh@debian:~$ ip tunnel delete
> Command "delete" is unknown, try "ip tunnel help".

Lets use "delete" in all calls to matches() for consistency. This will
make both "del" and "delete" work everywhere.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index d5bee36..c9720eb 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -408,7 +408,7 @@ int do_ip6tunnel(int argc, char **argv)
 			return do_add(SIOCADDTUNNEL, argc - 1, argv + 1);
 		if (matches(*argv, "change") == 0)
 			return do_add(SIOCCHGTUNNEL, argc - 1, argv + 1);
-		if (matches(*argv, "del") == 0)
+		if (matches(*argv, "delete") == 0)
 			return do_del(argc - 1, argv + 1);
 		if (matches(*argv, "show") == 0 ||
 		    matches(*argv, "lst") == 0 ||
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index c5683f5..3a5f94b 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -795,7 +795,7 @@ int do_ipl2tp(int argc, char **argv)
 
 	if (matches(*argv, "add") == 0)
 		return do_add(argc-1, argv+1);
-	if (matches(*argv, "del") == 0)
+	if (matches(*argv, "delete") == 0)
 		return do_del(argc-1, argv+1);
 	if (matches(*argv, "show") == 0 ||
 	    matches(*argv, "lst") == 0 ||
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 3d41a27..38ccd87 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -620,7 +620,7 @@ int do_iptunnel(int argc, char **argv)
 			return do_add(SIOCADDTUNNEL, argc-1, argv+1);
 		if (matches(*argv, "change") == 0)
 			return do_add(SIOCCHGTUNNEL, argc-1, argv+1);
-		if (matches(*argv, "del") == 0)
+		if (matches(*argv, "delete") == 0)
 			return do_del(argc-1, argv+1);
 		if (matches(*argv, "show") == 0 ||
 		    matches(*argv, "lst") == 0 ||
diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index 29f2777..20914e1 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -307,7 +307,7 @@ int do_iptuntap(int argc, char **argv)
 	if (argc > 0) {
 		if (matches(*argv, "add") == 0)
 			return do_add(argc-1, argv+1);
-		if (matches(*argv, "del") == 0)
+		if (matches(*argv, "delete") == 0)
 			return do_del(argc-1, argv+1);
 		if (matches(*argv, "show") == 0 ||
                     matches(*argv, "lst") == 0 ||
