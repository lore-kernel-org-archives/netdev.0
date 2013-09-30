From: Sami Kerola <kerolasa@iki.fi>
Subject: [PATCH] ip: make -resolve addr to print names rather than addresses
Date: Mon, 30 Sep 2013 22:01:48 +0100
Message-ID: <1380574908-9220-1-git-send-email-kerolasa@iki.fi>
Cc: kerolasa@iki.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33606 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755663Ab3I3VBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 17:01:55 -0400
Received: by mail-wi0-f171.google.com with SMTP id hm2so4572492wib.10
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 14:01:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a system admin I occasionally want to be able to check that all
interfaces has a name in DNS or /etc/hosts file.

Signed-off-by: Sami Kerola <kerolasa@iki.fi>
---
 ip/ipaddress.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 1c3e4da..d02eaaf 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -636,7 +636,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		fprintf(fp, "    family %d ", ifa->ifa_family);
 
 	if (rta_tb[IFA_LOCAL]) {
-		fprintf(fp, "%s", rt_addr_n2a(ifa->ifa_family,
+		fprintf(fp, "%s", format_host(ifa->ifa_family,
 					      RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
 					      RTA_DATA(rta_tb[IFA_LOCAL]),
 					      abuf, sizeof(abuf)));
@@ -647,7 +647,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 			fprintf(fp, "/%d ", ifa->ifa_prefixlen);
 		} else {
 			fprintf(fp, " peer %s/%d ",
-				rt_addr_n2a(ifa->ifa_family,
+				format_host(ifa->ifa_family,
 					    RTA_PAYLOAD(rta_tb[IFA_ADDRESS]),
 					    RTA_DATA(rta_tb[IFA_ADDRESS]),
 					    abuf, sizeof(abuf)),
@@ -657,14 +657,14 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 	if (rta_tb[IFA_BROADCAST]) {
 		fprintf(fp, "brd %s ",
-			rt_addr_n2a(ifa->ifa_family,
+			format_host(ifa->ifa_family,
 				    RTA_PAYLOAD(rta_tb[IFA_BROADCAST]),
 				    RTA_DATA(rta_tb[IFA_BROADCAST]),
 				    abuf, sizeof(abuf)));
 	}
 	if (rta_tb[IFA_ANYCAST]) {
 		fprintf(fp, "any %s ",
-			rt_addr_n2a(ifa->ifa_family,
+			format_host(ifa->ifa_family,
 				    RTA_PAYLOAD(rta_tb[IFA_ANYCAST]),
 				    RTA_DATA(rta_tb[IFA_ANYCAST]),
 				    abuf, sizeof(abuf)));
-- 
1.8.4
