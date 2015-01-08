From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Fix case when UDP is printed as ipproto-xxx
Date: Thu,  8 Jan 2015 02:42:54 +0200
Message-ID: <1420677774-10288-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:49547 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755499AbbAHAxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 19:53:18 -0500
Received: by mail-lb0-f178.google.com with SMTP id u14so415889lbd.9
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 16:53:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

When 'ss' prints UDP sockets info together with RAW sockets
e.g.:

    $ ss -a

then UDP sockets are resolved as "ipproto-xxx".

It was caused that dg_proto was set after printing UDP
socket info from netlink. So fixed issue by moving
setting dg_proto before printing info from Netlink.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 08d210a..7c94463 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2287,12 +2287,12 @@ static int udp_show(struct filter *f)
 {
 	FILE *fp = NULL;
 
+	dg_proto = UDP_PROTO;
+
 	if (!getenv("PROC_NET_UDP") && !getenv("PROC_ROOT")
 	    && inet_show_netlink(f, NULL, IPPROTO_UDP) == 0)
 		return 0;
 
-	dg_proto = UDP_PROTO;
-
 	if (f->families&(1<<AF_INET)) {
 		if ((fp = net_udp_open()) == NULL)
 			goto outerr;
-- 
2.1.3
