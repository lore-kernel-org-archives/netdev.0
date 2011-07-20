From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] Fix error decoding router advertisements netlink messages
Date: Wed, 20 Jul 2011 10:41:21 +0200
Message-ID: <1311151281-25479-1-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org,
	Christoph Biedl <debian.axhn@manchmal.in-ulm.de>,
	Andreas Henriksson <andreas@fatal.se>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:55977 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab1GTImb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 04:42:31 -0400
Received: from ipb4.telenor.se (ipb4.telenor.se [195.54.127.167])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id 3C6BDEA0C8
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 10:42:28 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Biedl <debian.axhn@manchmal.in-ulm.de>

The "ip monitor" command does properly decode the "preferred" and
"valid" lifetime records in router advertisements from netlink
messages.

For more details see http://bugs.debian.org/634170

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 ip/ipprefix.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ip/ipprefix.c b/ip/ipprefix.c
index cb1f582..d8327be 100644
--- a/ip/ipprefix.c
+++ b/ip/ipprefix.c
@@ -92,7 +92,7 @@ int print_prefix(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (tb[PREFIX_CACHEINFO]) {
 		struct prefix_cacheinfo *pc;
-		pc = (struct prefix_cacheinfo *)tb[PREFIX_CACHEINFO];
+		pc = (struct prefix_cacheinfo *)RTA_DATA(tb[PREFIX_CACHEINFO]);
 
 		fprintf(fp, "valid %u ", pc->valid_time);
 		fprintf(fp, "preferred %u ", pc->preferred_time);
-- 
1.7.5.4

