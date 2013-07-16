From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] ipadress: fix display of IPv6 peer address
Date: Tue, 16 Jul 2013 22:52:48 +0200
Message-ID: <1374007968-11287-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40104 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741Ab3GPUxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 16:53:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because only IPv4 was supported, the size was static. Now, IPv6 also supports
peer address.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipaddress.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 5b9a43854514..2b3707af8be4 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -613,7 +613,8 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 					      abuf, sizeof(abuf)));
 
 		if (rta_tb[IFA_ADDRESS] == NULL ||
-		    memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]), RTA_DATA(rta_tb[IFA_LOCAL]), 4) == 0) {
+		    memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]), RTA_DATA(rta_tb[IFA_LOCAL]),
+			   ifa->ifa_family == AF_INET ? 4 : 16) == 0) {
 			fprintf(fp, "/%d ", ifa->ifa_prefixlen);
 		} else {
 			fprintf(fp, " peer %s/%d ",
-- 
1.8.2.1
