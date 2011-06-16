From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 1/2] sctp: HEARTBEAT negotiation after ASCONF
Date: Thu, 16 Jun 2011 17:56:42 +0900
Message-ID: <9C3219F3-AD39-40CF-8422-241D26ECA4D7@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:60088 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757117Ab1FPI4m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 04:56:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 6780e27850126dc200a8700a0f8c3105971b8978 Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Thu, 16 Jun 2011 10:54:23 +0900
Subject: [PATCH 1/2] sctp: HEARTBEAT negotiation after ASCONF

This patch fixes BUG that the ASCONF receiver transmits DATA chunks
to the newly added UNCONFIRMED destination.

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
 net/sctp/outqueue.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index edc7532..4adfc1e 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -917,6 +917,8 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 		 * current cwnd).
 		 */
 		if (!list_empty(&q->retransmit)) {
+			if (asoc->peer.retran_path->state == SCTP_UNCONFIRMED) 
+				goto sctp_flush_out;
 			if (transport == asoc->peer.retran_path)
 				goto retran;
 
@@ -989,6 +991,8 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 			    ((new_transport->state == SCTP_INACTIVE) ||
 			     (new_transport->state == SCTP_UNCONFIRMED)))
 				new_transport = asoc->peer.active_path;
+			if (new_transport->state == SCTP_UNCONFIRMED) 
+				continue;
 
 			/* Change packets if necessary.  */
 			if (new_transport != transport) {
-- 
1.7.3.2


