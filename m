From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Remove checking SS_CLOSE state for packet and netlink
Date: Thu, 16 Oct 2014 11:19:29 +0300
Message-ID: <1413447569-11601-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:50106 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaJPI20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 04:28:26 -0400
Received: by mail-wg0-f50.google.com with SMTP id a1so3090695wgh.21
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 01:28:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I dont see a reason that packet and netlink states will be
printed only if SS_CLOSE state is set in filter, in that case
to print states of netlink or packet sockets it is needed to run:

    ss -A netlink state close

instead of:

    ss -A netlink

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 2420b51..2500c87 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2882,9 +2882,6 @@ static int packet_show(struct filter *f)
 	int ino;
 	unsigned long long sk;
 
-	if (!(f->states & (1<<SS_CLOSE)))
-		return 0;
-
 	if (packet_show_netlink(f, NULL) == 0)
 		return 0;
 
@@ -3119,9 +3116,6 @@ static int netlink_show(struct filter *f)
 	int rq, wq, rc;
 	unsigned long long sk, cb;
 
-	if (!(f->states & (1<<SS_CLOSE)))
-		return 0;
-
 	if (!getenv("PROC_NET_NETLINK") && !getenv("PROC_ROOT") &&
 		netlink_show_netlink(f, NULL) == 0)
 		return 0;
-- 
2.1.0
