From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH iproute2] tc: u32: Fix firstfrag filter.
Date: Tue, 10 Jul 2012 19:44:16 +0900
Message-ID: <20120710194416.8edccfdcb47542a5ac2d9e0b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60906 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab2GJKoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 06:44:19 -0400
Received: by pbbrp8 with SMTP id rp8so94837pbb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 03:44:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On current firstfrag filter, all non fragmented packets are matched.
firstfrag should check MF bit.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
Maybe no one uses this filter.

 tc/f_u32.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index 7a04634..66c3247 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -513,7 +513,7 @@ static int parse_ip(int *argc_p, char ***argv_p, struct tc_u32_sel *sel)
 		res = pack_key16(sel, 0, 0x3FFF, 6, 0);
 	} else if (strcmp(*argv, "firstfrag") == 0) {
 		argc--; argv++;
-		res = pack_key16(sel, 0, 0x1FFF, 6, 0);
+		res = pack_key16(sel, 0x2000, 0x3FFF, 6, 0);
 	} else if (strcmp(*argv, "df") == 0) {
 		argc--; argv++;
 		res = pack_key16(sel, 0x4000, 0x4000, 6, 0);
-- 
1.7.8.6
