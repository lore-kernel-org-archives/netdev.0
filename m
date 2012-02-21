From: Dave Jones <davej@redhat.com>
Subject: return 0 when MSG_OOB in ping_recvmsg
Date: Tue, 21 Feb 2012 17:50:59 -0500
Message-ID: <20120221225058.GA15387@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62535 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753458Ab2BUWvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 17:51:01 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q1LMp177003302
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 17:51:01 -0500
Received: from gelk.kernelslacker.org (ovpn-113-139.phx2.redhat.com [10.3.113.139])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q1LMp0FS021327
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 17:51:01 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id q1LMoxpE015486
	for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 17:50:59 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id q1LMoxeS015485
	for netdev@vger.kernel.org; Tue, 21 Feb 2012 17:50:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a packet causes the 'if (flags & MSG_OOB)' test this function does first
thing is true, it returns an uninitialised variable from the stack.

There may be a better return code for this failure, but returning
'0 bytes copied' seems better than just returning garbage.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index aea5a19..0823562 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -626,7 +626,7 @@ static int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct inet_sock *isk = inet_sk(sk);
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
 	struct sk_buff *skb;
-	int copied, err;
+	int copied, err = 0;
 
 	pr_debug("ping_recvmsg(sk=%p,sk->num=%u)\n", isk, isk->inet_num);
 
