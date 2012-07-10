From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH iproute2] tc: u32: Fix icmp_code off.
Date: Tue, 10 Jul 2012 18:53:18 +0900
Message-ID: <20120710185318.075fc257cb6b9a2c8ae66479@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61729 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754789Ab2GJJxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 05:53:22 -0400
Received: by pbbrp8 with SMTP id rp8so33261pbb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 02:53:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The off of icmp_code is not 20 but 21. Also offmask should be 0 unless
nexthdr+ is specified.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 tc/f_u32.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index 975c0b5..7a04634 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -531,7 +531,7 @@ static int parse_ip(int *argc_p, char ***argv_p, struct tc_u32_sel *sel)
 		res = parse_u8(&argc, &argv, sel, 20, 0);
 	} else if (strcmp(*argv, "icmp_code") == 0) {
 		NEXT_ARG();
-		res = parse_u8(&argc, &argv, sel, 20, 1);
+		res = parse_u8(&argc, &argv, sel, 21, 0);
 	} else
 		return -1;
 
-- 
1.7.8.6
