From: Sangtae Ha <sangtae.ha@gmail.com>
Subject: [PATCH 1/3] tcp_cubic: fix train length comparision
Date: Sun, 13 Mar 2011 20:03:12 -0400
Message-ID: <1300060992-24151-1-git-send-email-sangtae.ha@gmail.com>
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Injong Rhee <rhee@ncsu.edu>,
	Bill Fink <billfink@mindspring.com>, <netdev@vger.kernel.org>,
	Sangtae Ha <sangtae.ha@gmail.com>
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:37033 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756627Ab1CNADc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 20:03:32 -0400
Received: by qyk7 with SMTP id 7so978865qyk.19
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2011 17:03:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HyStart detects the safe exit point when the ACK train length is
larger than the one-way delay. This needs to be applied after
the patches Stephen made to fix clock dependency of HyStart.

Signed-off-by: Sangtae Ha <sangtae.ha@gmail.com>
---
 net/ipv4/tcp_cubic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 91ef5e6..ab9f888 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -356,7 +356,7 @@ static void hystart_update(struct sock *sk, u32 delay)
 		/* first detection parameter - ack-train detection */
 		if ((s32)(now - ca->last_ack) <= hystart_ack_delta) {
 			ca->last_ack = now;
-			if ((s32)(now - ca->round_start) <= ca->delay_min >> 4)
+			if ((s32)(now - ca->round_start) > ca->delay_min >> 4)
 				ca->found |= HYSTART_ACK_TRAIN;
 		}
 
-- 
1.7.0.4

