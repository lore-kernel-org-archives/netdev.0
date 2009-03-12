From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 2/4] sctp: fix to indicate ASCONF support in INIT-ACK only if peer has such capable
Date: Thu, 12 Mar 2009 15:49:18 -0400
Message-ID: <1236887360-1904-3-git-send-email-vladislav.yasevich@hp.com>
References: <1236887360-1904-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:22542 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400AbZCLTt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:49:26 -0400
In-Reply-To: <1236887360-1904-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

This patch fix to indicate ASCONF support in INIT-ACK only if peer has
such capable.

This patch also fix to calc the chunk size if peer has no FWD-TSN
capable.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_make_chunk.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index b40e95f..9484f33 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -372,10 +372,10 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	if (asoc->peer.ecn_capable)
 		chunksize += sizeof(ecap_param);
 
-	if (sctp_prsctp_enable)
+	if (asoc->peer.prsctp_capable)
 		chunksize += sizeof(prsctp_param);
 
-	if (sctp_addip_enable) {
+	if (asoc->peer.asconf_capable) {
 		extensions[num_ext] = SCTP_CID_ASCONF;
 		extensions[num_ext+1] = SCTP_CID_ASCONF_ACK;
 		num_ext += 2;
-- 
1.5.4.3

