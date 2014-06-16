From: Dave Jones <davej@redhat.com>
Subject: tcp: remove unnecessary tcp_sk assignment.
Date: Mon, 16 Jun 2014 16:30:36 -0400
Message-ID: <20140616203036.GA2879@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24411 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755841AbaFPUan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2014 16:30:43 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s5GKUhnQ029202
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 16:30:43 -0400
Received: from gelk.kernelslacker.org (ovpn-113-41.phx2.redhat.com [10.3.113.41])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s5GKUblD023023
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 16:30:43 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.8/8.14.7) with ESMTP id s5GKUbOB006556
	for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 16:30:37 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.8/8.14.8/Submit) id s5GKUa9A006555
	for netdev@vger.kernel.org; Mon, 16 Jun 2014 16:30:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This variable is overwritten by the child socket assignment before
it ever gets used.
    
Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 62e48cf84e60..9771563ab564 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -131,7 +131,7 @@ static bool tcp_fastopen_create_child(struct sock *sk,
 				      struct dst_entry *dst,
 				      struct request_sock *req)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_sock *tp;
 	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
 	struct sock *child;
 
