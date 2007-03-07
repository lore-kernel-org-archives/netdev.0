From: Noriaki TAKAMIYA <takamiya@linux-ipv6.org>
Subject: [IPROUTE][IP]: enabled to manipulate the flags of
 IFA_F_HOMEADDRESS or IFA_F_NODAD from ip.
Date: Thu, 08 Mar 2007 03:15:43 +0900 (JST)
Message-ID: <20070308.031543.465784743.takamiya@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nakam@linux-ipv6.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from linux6.nezu.wide.ad.jp ([203.178.142.218]:48146 "EHLO
	nezu.linux-ipv6.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422943AbXCGS2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 13:28:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 

  This patch enables ip command to add IFA_F_HOMEADDRESS and
  IFA_F_NODAD flags while adding the IPv6 address.

Signed-off-by: Noriaki TAKAMIYA<takamiya@po.ntts.co.jp>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

---
 ip/ipaddress.c |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index cae1fcd..98effa3 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -61,6 +61,7 @@ static void usage(void)
 		iplink_usage();
 	}
 	fprintf(stderr, "Usage: ip addr {add|change|replace} IFADDR dev STRING [ LIFETIME ]\n");
+	fprintf(stderr, "                                                      [ CONFFLAG-LIST]\n");
 	fprintf(stderr, "       ip addr del IFADDR dev STRING\n");
 	fprintf(stderr, "       ip addr {show|flush} [ dev STRING ] [ scope SCOPE-ID ]\n");
 	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIST ] [ label PATTERN ]\n");
@@ -70,7 +71,9 @@ static void usage(void)
 	fprintf(stderr, "SCOPE-ID := [ host | link | global | NUMBER ]\n");
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
 	fprintf(stderr, "FLAG  := [ permanent | dynamic | secondary | primary |\n");
-	fprintf(stderr, "           tentative | deprecated ]\n");
+	fprintf(stderr, "           tentative | deprecated | CONFFLAG-LIST ]\n");
+	fprintf(stderr, "CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG\n");
+	fprintf(stderr, "CONFFLAG  := [ home | nodad ]\n");
 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
 	fprintf(stderr, "LFT := forever | SECONDS\n");
 
@@ -427,6 +430,14 @@ int print_addrinfo(const struct sockaddr
 		ifa->ifa_flags &= ~IFA_F_DEPRECATED;
 		fprintf(fp, "deprecated ");
 	}
+	if (ifa->ifa_flags&IFA_F_HOMEADDRESS) {
+		ifa->ifa_flags &= ~IFA_F_HOMEADDRESS;
+		fprintf(fp, "home ");
+	}
+	if (ifa->ifa_flags&IFA_F_NODAD) {
+		ifa->ifa_flags &= ~IFA_F_NODAD;
+		fprintf(fp, "nodad ");
+	}
 	if (!(ifa->ifa_flags&IFA_F_PERMANENT)) {
 		fprintf(fp, "dynamic ");
 	} else
@@ -567,6 +578,12 @@ int ipaddr_list_or_flush(int argc, char
 		} else if (strcmp(*argv, "deprecated") == 0) {
 			filter.flags |= IFA_F_DEPRECATED;
 			filter.flagmask |= IFA_F_DEPRECATED;
+		} else if (strcmp(*argv, "home") == 0) {
+			filter.flags |= IFA_F_HOMEADDRESS;
+			filter.flagmask |= IFA_F_HOMEADDRESS;
+		} else if (strcmp(*argv, "nodad") == 0) {
+			filter.flags |= IFA_F_NODAD;
+			filter.flagmask |= IFA_F_NODAD;
 		} else if (strcmp(*argv, "label") == 0) {
 			NEXT_ARG();
 			filter.label = *argv;
@@ -844,6 +861,10 @@ int ipaddr_modify(int cmd, int flags, in
 			preferred_lftp = *argv;
 			if (set_lifetime(&preferred_lft, *argv))
 				invarg("preferred_lft value", *argv);
+		} else if (strcmp(*argv, "home") == 0) {
+			req.ifa.ifa_flags |= IFA_F_HOMEADDRESS;
+		} else if (strcmp(*argv, "nodad") == 0) {
+			req.ifa.ifa_flags |= IFA_F_NODAD;
 		} else {
 			if (strcmp(*argv, "local") == 0) {
 				NEXT_ARG();
-- 
Noriaki TAKAMIYA
