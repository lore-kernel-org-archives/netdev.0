From: Brian Haley <brian.haley@hp.com>
Subject: [iproute2]: fix support for IFA_F_DADFAILED
Date: Thu, 03 Dec 2009 15:39:36 -0500
Message-ID: <4B182208.8010707@hp.com>
References: <4AAEAEE7.4090507@hp.com>	<4B1813E7.2030004@hp.com> <20091203121015.7a7c069e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:26027 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755618AbZLCUlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:41:17 -0500
In-Reply-To: <20091203121015.7a7c069e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Delta would be easier.

Ok, here it is.

-Brian


Fix support for IFA_F_DADFAILED and update ip.8 man page.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index f0add80..581722a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -62,7 +62,7 @@ static void usage(void)
 		iplink_usage();
 	}
 	fprintf(stderr, "Usage: ip addr {add|change|replace} IFADDR dev STRING [ LIFETIME ]\n");
-	fprintf(stderr, "                                                      [ CONFFLAG-LIST]\n");
+	fprintf(stderr, "                                                      [ CONFFLAG-LIST ]\n");
 	fprintf(stderr, "       ip addr del IFADDR dev STRING\n");
 	fprintf(stderr, "       ip addr {show|flush} [ dev STRING ] [ scope SCOPE-ID ]\n");
 	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIST ] [ label PATTERN ]\n");
@@ -72,7 +72,8 @@ static void usage(void)
 	fprintf(stderr, "SCOPE-ID := [ host | link | global | NUMBER ]\n");
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
 	fprintf(stderr, "FLAG  := [ permanent | dynamic | secondary | primary |\n");
-	fprintf(stderr, "           tentative | deprecated | CONFFLAG-LIST ]\n");
+	fprintf(stderr, "           tentative | deprecated | dadfailed |\n");
+	fprintf(stderr, "           CONFFLAG-LIST ]\n");
 	fprintf(stderr, "CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG\n");
 	fprintf(stderr, "CONFFLAG  := [ home | nodad ]\n");
 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
@@ -657,6 +658,9 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		} else if (strcmp(*argv, "nodad") == 0) {
 			filter.flags |= IFA_F_NODAD;
 			filter.flagmask |= IFA_F_NODAD;
+		} else if (strcmp(*argv, "dadfailed") == 0) {
+			filter.flags |= IFA_F_DADFAILED;
+			filter.flagmask |= IFA_F_DADFAILED;
 		} else if (strcmp(*argv, "label") == 0) {
 			NEXT_ARG();
 			filter.label = *argv;
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index a8fccc4..1145b28 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -97,7 +97,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .ti -8
 .IR FLAG " := "
 .RB "[ " permanent " | " dynamic " | " secondary " | " primary " | "\
-tentative " | " deprecated " ]"
+tentative " | " deprecated " | " dadfailed " ]"
 
 .ti -8
 .BR "ip addrlabel" " { " add " | " del " } " prefix
@@ -1030,7 +1030,7 @@ addresses.
 
 .TP
 .B tentative
-(IPv6 only) only list addresses which did not pass duplicate
+(IPv6 only) only list addresses which have not yet passed duplicate
 address detection.
 
 .TP
@@ -1038,6 +1038,11 @@ address detection.
 (IPv6 only) only list deprecated addresses.
 
 .TP
+.B dadfailed
+(IPv6 only) only list addresses which have failed duplicate
+address detection.
+
+.TP
 .BR primary " and " secondary
 only list primary (or secondary) addresses.
 
