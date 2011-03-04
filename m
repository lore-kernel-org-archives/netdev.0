From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 3/4] sctp: several declared/set but unused fixes
Date: Fri,  4 Mar 2011 22:45:05 +0100
Message-ID: <1299275106-11513-3-git-send-email-hagen@jauu.net>
References: <1299275106-11513-1-git-send-email-hagen@jauu.net>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:39157 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760254Ab1CDVpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 16:45:10 -0500
In-Reply-To: <1299275106-11513-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/sctp/associola.c     |    2 --
 net/sctp/input.c         |    3 ---
 net/sctp/outqueue.c      |    2 --
 net/sctp/sm_make_chunk.c |    3 ---
 net/sctp/socket.c        |    2 --
 net/sctp/ulpqueue.c      |    7 +------
 6 files changed, 1 insertions(+), 18 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 5f1fb8b..6b04287 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1089,7 +1089,6 @@ static void sctp_assoc_bh_rcv(struct work_struct *work)
 			     base.inqueue.immediate);
 	struct sctp_endpoint *ep;
 	struct sctp_chunk *chunk;
-	struct sock *sk;
 	struct sctp_inq *inqueue;
 	int state;
 	sctp_subtype_t subtype;
@@ -1097,7 +1096,6 @@ static void sctp_assoc_bh_rcv(struct work_struct *work)
 
 	/* The association should be held so we should be safe. */
 	ep = asoc->ep;
-	sk = asoc->base.sk;
 
 	inqueue = &asoc->base.inqueue;
 	sctp_association_hold(asoc);
diff --git a/net/sctp/input.c b/net/sctp/input.c
index ea21924..826661b 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -948,14 +948,11 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct sk_buff *skb,
 	union sctp_addr addr;
 	union sctp_addr *paddr = &addr;
 	struct sctphdr *sh = sctp_hdr(skb);
-	sctp_chunkhdr_t *ch;
 	union sctp_params params;
 	sctp_init_chunk_t *init;
 	struct sctp_transport *transport;
 	struct sctp_af *af;
 
-	ch = (sctp_chunkhdr_t *) skb->data;
-
 	/*
 	 * This code will NOT touch anything inside the chunk--it is
 	 * strictly READ-ONLY.
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 8c6d379..26dc005 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -545,13 +545,11 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 	struct sctp_transport *transport = pkt->transport;
 	sctp_xmit_t status;
 	struct sctp_chunk *chunk, *chunk1;
-	struct sctp_association *asoc;
 	int fast_rtx;
 	int error = 0;
 	int timer = 0;
 	int done = 0;
 
-	asoc = q->asoc;
 	lqueue = &q->retransmit;
 	fast_rtx = q->fast_rtx;
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index b23428f..de98665 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3375,7 +3375,6 @@ struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
 				    struct sctp_fwdtsn_skip *skiplist)
 {
 	struct sctp_chunk *retval = NULL;
-	struct sctp_fwdtsn_chunk *ftsn_chunk;
 	struct sctp_fwdtsn_hdr ftsn_hdr;
 	struct sctp_fwdtsn_skip skip;
 	size_t hint;
@@ -3388,8 +3387,6 @@ struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
 	if (!retval)
 		return NULL;
 
-	ftsn_chunk = (struct sctp_fwdtsn_chunk *)retval->subh.fwdtsn_hdr;
-
 	ftsn_hdr.new_cum_tsn = htonl(new_cum_tsn);
 	retval->subh.fwdtsn_hdr =
 		sctp_addto_chunk(retval, sizeof(ftsn_hdr), &ftsn_hdr);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index b53b2eb..3951a10 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2928,7 +2928,6 @@ static int sctp_setsockopt_peer_primary_addr(struct sock *sk, char __user *optva
 					     unsigned int optlen)
 {
 	struct sctp_sock	*sp;
-	struct sctp_endpoint	*ep;
 	struct sctp_association	*asoc = NULL;
 	struct sctp_setpeerprim	prim;
 	struct sctp_chunk	*chunk;
@@ -2936,7 +2935,6 @@ static int sctp_setsockopt_peer_primary_addr(struct sock *sk, char __user *optva
 	int 			err;
 
 	sp = sctp_sk(sk);
-	ep = sp->ep;
 
 	if (!sctp_addip_enable)
 		return -EPERM;
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index c7f7e49..1767818 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -105,11 +105,8 @@ int sctp_ulpq_tail_data(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
 			gfp_t gfp)
 {
 	struct sk_buff_head temp;
-	sctp_data_chunk_t *hdr;
 	struct sctp_ulpevent *event;
 
-	hdr = (sctp_data_chunk_t *) chunk->chunk_hdr;
-
 	/* Create an event from the incoming chunk. */
 	event = sctp_ulpevent_make_rcvmsg(chunk->asoc, chunk, gfp);
 	if (!event)
@@ -743,11 +740,9 @@ static void sctp_ulpq_retrieve_ordered(struct sctp_ulpq *ulpq,
 	struct sk_buff *pos, *tmp;
 	struct sctp_ulpevent *cevent;
 	struct sctp_stream *in;
-	__u16 sid, csid;
-	__u16 ssn, cssn;
+	__u16 sid, csid, cssn;
 
 	sid = event->stream;
-	ssn = event->ssn;
 	in  = &ulpq->asoc->ssnmap->in;
 
 	event_list = (struct sk_buff_head *) sctp_event2skb(event)->prev;
-- 
1.7.4.1.57.g0466.dirty

