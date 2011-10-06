From: Petr Sabata <contyk@redhat.com>
Subject: [PATCH 1/3] iproute2: ss - fix missing parameters
Date: Thu,  6 Oct 2011 14:45:32 +0200
Message-ID: <1317905134-23175-2-git-send-email-contyk@redhat.com>
References: <1317905134-23175-1-git-send-email-contyk@redhat.com>
Cc: Petr Sabata <contyk@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46431 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758260Ab1JFMrj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 08:47:39 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p96ClceK009938
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 08:47:38 -0400
In-Reply-To: <1317905134-23175-1-git-send-email-contyk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Petr Sabata <contyk@redhat.com>
---
 man/man8/ss.8 |    4 ++--
 misc/ss.c     |    6 ++++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index b309df2..0b9a8c4 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -85,12 +85,12 @@ Display Unix domain sockets (alias for -f unix).
 Display sockets of type FAMILY.
 Currently the following families are supported: unix, inet, inet6, link, netlink.
 .TP
-.B \-A QUERY, \-\-query=QUERY
+.B \-A QUERY, \-\-query=QUERY, \-\-socket=QUERY
 List of socket tables to dump, separated by commas. The following identifiers
 are understood: all, inet, tcp, udp, raw, unix, packet, netlink, unix_dgram,
 unix_stream, packet_raw, packet_dgram.
 .TP
-.B \-D FILE
+.B \-D FILE, \-\-diag=FILE
 Do not display anything, just dump raw information about TCP sockets to FILE after applying filters. If FILE is - stdout is used.
 .TP
 .B \-F FILE, \-\-filter=FILE
diff --git a/misc/ss.c b/misc/ss.c
index 1597ff9..253f8d3 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2416,9 +2416,10 @@ static void _usage(FILE *dest)
 "   -x, --unix		display only Unix domain sockets\n"
 "   -f, --family=FAMILY display sockets of type FAMILY\n"
 "\n"
-"   -A, --query=QUERY\n"
+"   -A, --query=QUERY, --socket=QUERY\n"
 "       QUERY := {all|inet|tcp|udp|raw|unix|packet|netlink}[,QUERY]\n"
 "\n"
+"   -D, --diag=FILE     Dump raw information about TCP sockets to FILE\n"
 "   -F, --filter=FILE   read filter information from FILE\n"
 "       FILTER := [ state TCP-STATE ] [ EXPRESSION ]\n"
 		);
@@ -2486,8 +2487,9 @@ static const struct option long_opts[] = {
 	{ "packet", 0, 0, '0' },
 	{ "family", 1, 0, 'f' },
 	{ "socket", 1, 0, 'A' },
+	{ "query", 1, 0, 'A' },
 	{ "summary", 0, 0, 's' },
-	{ "diag", 0, 0, 'D' },
+	{ "diag", 1, 0, 'D' },
 	{ "filter", 1, 0, 'F' },
 	{ "version", 0, 0, 'V' },
 	{ "help", 0, 0, 'h' },
-- 
1.7.6.4
