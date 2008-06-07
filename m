From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next] sctp: Fix problems with the new SCTP_DELAYED_ACK code
Date: Fri,  6 Jun 2008 22:50:07 -0400
Message-ID: <1212807007-24379-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:40339 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822AbYFGCuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 22:50:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default sack frequency should be 2.  Also fix copy/paste
error when updating all transports.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 81600ee..253e5ea 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2471,7 +2471,7 @@ static int sctp_setsockopt_delayed_ack(struct sock *sk,
 					(trans->param_flags & ~SPP_SACKDELAY) |
 					SPP_SACKDELAY_ENABLE;
 			}
-			if (params.sack_delay == 1) {
+			if (params.sack_freq == 1) {
 				trans->param_flags =
 					(trans->param_flags & ~SPP_SACKDELAY) |
 					SPP_SACKDELAY_DISABLE;
@@ -3536,7 +3536,7 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	sp->pathmaxrxt  = sctp_max_retrans_path;
 	sp->pathmtu     = 0; // allow default discovery
 	sp->sackdelay   = sctp_sack_timeout;
-	sp->sackfreq	= 3;
+	sp->sackfreq	= 2;
 	sp->param_flags = SPP_HB_ENABLE |
 			  SPP_PMTUD_ENABLE |
 			  SPP_SACKDELAY_ENABLE;
-- 
1.5.3.5

