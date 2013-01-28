From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] iplink: display the value of IFLA_PROMISCUITY
Date: Mon, 28 Jan 2013 15:38:18 +0100
Message-ID: <1359383898-8047-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57567 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757309Ab3A1Orz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 09:47:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is usefull to know the 'real' status of an interface (the flag IFF_PROMISC
is exported by the kernel only when the user set it explicitly, for example it
will not be exported when a tcpdump is running).

Note that I add a space after qlen (instead of before promiscuity) to be
coherent with the rest of the code.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipaddress.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 5498f46..0d988ae 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -171,7 +171,7 @@ static void print_queuelen(FILE *f, struct rtattr *tb[IFLA_MAX + 1])
 		qlen = ifr.ifr_qlen;
 	}
 	if (qlen)
-		fprintf(f, "qlen %d", qlen);
+		fprintf(f, "qlen %d ", qlen);
 }
 
 static const char *link_modes[] = {
@@ -438,6 +438,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (filter.showqueue)
 		print_queuelen(fp, tb);
 
+	if (tb[IFLA_PROMISCUITY] && *(int*)RTA_DATA(tb[IFLA_PROMISCUITY]) > 0)
+		fprintf(fp, "promiscuity %u ", *(int*)RTA_DATA(tb[IFLA_PROMISCUITY]));
+
 	if (!filter.family || filter.family == AF_PACKET) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "%s", _SL_);
-- 
1.8.0.1
