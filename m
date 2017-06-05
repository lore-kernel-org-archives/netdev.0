From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 net-next] ip neigh: allow flush FAILED neighbour entry
Date: Mon,  5 Jun 2017 16:31:29 +0800
Message-ID: <1496651489-28110-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34679 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751437AbdFEIcL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 04:32:11 -0400
Received: by mail-pf0-f196.google.com with SMTP id w69so19947227pfk.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 01:32:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After upstream commit 5071034e4af7 ('neigh: Really delete an arp/neigh entry
on "ip neigh delete" or "arp -d"'), we could delete a single FAILED neighbour
entry now. But `ip neigh flush` still skip the FAILED entry.

Let's remove this filter so we can also flush FAILED entry.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/ipneigh.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 4d8fc85..8082fa8 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -445,7 +445,6 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 		filter.flushb = flushb;
 		filter.flushp = 0;
 		filter.flushe = sizeof(flushb);
-		filter.state &= ~NUD_FAILED;
 
 		while (round < MAX_ROUNDS) {
 			if (rtnl_dump_request_n(&rth, &req.n) < 0) {
-- 
2.5.5
