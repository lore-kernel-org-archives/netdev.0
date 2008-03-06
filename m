From: Patrick McManus <mcmanus@ducksong.com>
Subject: [PATCH 1/3 resend] TCP_DEFER_ACCEPT updates - defer timeout
	conflics with max_thresh
Date: Thu, 06 Mar 2008 18:51:12 -0500
Message-ID: <1204847472.17097.17.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:50755 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756229AbYCFXu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:50:56 -0500
Received: from [192.168.16.214] (cpe-76-179-219-229.maine.res.rr.com [76.179.219.229])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by linode.ducksong.com (Postfix) with ESMTP id BB61A10162
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 18:50:55 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 077b5f8e36b93e5121f680c3bb327e7464020fd2
Author: Patrick McManus <mcmanus@ducksong.com>
Date:   Sat Feb 23 12:23:47 2008 -0500

    timeout associated with SO_DEFER_ACCEPT wasn't being honored if it was
    less than the timeout allowed by the maximum syn-recv queue size
    algorithm. Fix by using the SO_DEFER_ACCEPT value if the ack has
    arrived.
    
    Signed-off-by: Patrick McManus <mcmanus@ducksong.com>
    Acked-by: Eric Dumazet <dada1@cosmosbay.com>
    
    ---

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index b189278..03cc323 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -461,8 +461,7 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		reqp=&lopt->syn_table[i];
 		while ((req = *reqp) != NULL) {
 			if (time_after_eq(now, req->expires)) {
-				if ((req->retrans < thresh ||
-				     (inet_rsk(req)->acked && req->retrans < max_retries))
+				if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh))
 				    && !req->rsk_ops->rtx_syn_ack(parent, req, NULL)) {
 					unsigned long timeo;
 


