From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Filter inet dgram sockets with established state by default
Date: Thu,  8 Jan 2015 19:32:22 +0200
Message-ID: <1420738342-3750-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:37266 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754622AbbAHRmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 12:42:47 -0500
Received: by mail-lb0-f176.google.com with SMTP id p9so4160062lbv.7
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 09:42:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

As inet dgram sockets (udp, raw) can call connect(...)  - they
might be set in ESTABLISHED state. So keep the original behaviour of
'ss' which filtered them by ESTABLISHED state by default. So:

    $ ss -u

    or

    $ ss -w

Will show only ESTABLISHED UDP sockets by default.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 08d210a..015d829 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -170,11 +170,11 @@ static const struct filter default_dbs[MAX_DB] = {
 		.families = (1 << AF_INET) | (1 << AF_INET6),
 	},
 	[UDP_DB] = {
-		.states   = (1 << SS_CLOSE),
+		.states   = (1 << SS_ESTABLISHED),
 		.families = (1 << AF_INET) | (1 << AF_INET6),
 	},
 	[RAW_DB] = {
-		.states   = (1 << SS_CLOSE),
+		.states   = (1 << SS_ESTABLISHED),
 		.families = (1 << AF_INET) | (1 << AF_INET6),
 	},
 	[UNIX_DG_DB] = {
-- 
2.1.3
