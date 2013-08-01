From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH] ip link: fix display and filtering of ifgroups
Date: Thu, 1 Aug 2013 14:16:36 +0200
Message-ID: <20130801121636.GA21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:38566 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450Ab3HAMQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 08:16:37 -0400
Received: from stefan by zirkel.wertarbyte.de with local (Exim 4.72)
	(envelope-from <stefan.tomanek@wertarbyte.de>)
	id 1V4ro4-0004l8-VQ
	for netdev@vger.kernel.org; Thu, 01 Aug 2013 14:16:36 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds the interface group to the output of "ip link show".

It also makes "ip link" print _all_ devices if no group filter is specified;
previously, only interfaces of the default group (0) were shown.

Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 ip/ipaddress.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 013b4cb..cf4015a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -418,7 +418,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 	if (tb[IFLA_GROUP]) {
 		int group = *(int*)RTA_DATA(tb[IFLA_GROUP]);
-		if (group != filter.group)
+		if (filter.group != -1 && group != filter.group)
 			return -1;
 	}
 
@@ -458,6 +458,11 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (do_link && tb[IFLA_LINKMODE])
 		print_linkmode(fp, tb[IFLA_LINKMODE]);
 
+	if (tb[IFLA_GROUP]) {
+		int group = *(int*)RTA_DATA(tb[IFLA_GROUP]);
+		fprintf(fp, "group %d ", group);
+	}
+
 	if (filter.showqueue)
 		print_queuelen(fp, tb);
 
@@ -1050,7 +1055,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 	if (filter.family == AF_UNSPEC)
 		filter.family = preferred_family;
 
-	filter.group = INIT_NETDEV_GROUP;
+	filter.group = -1;
 
 	if (action == IPADD_FLUSH) {
 		if (argc <= 0) {
-- 
1.7.10.4
