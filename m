From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [NET]: Please revert disallowing zero listen queues
Date: Tue, 6 Mar 2007 13:32:09 +0000
Message-ID: <200703061332.09677@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weid@np.css.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:45996 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964988AbXCFNo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 08:44:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please can you reconsider the patch regarding the accept_queue

http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.22.git;a=commit;h=8488df894d05d6fa41c2bd298c335f944bb0e401

It disallows to set a `backlog' argument to listen(2) of zero. Using
a zero backlog is often done (e.g. ttcp), and disallowing a zero 
backlog will break many applications. I had to recode several applications
which rely on this convention.

The problem further spreads from TCP to DCCP (same behaviour).

Below is a patch to revert this change.

Thank you 
Gerrit

diff --git a/include/net/sock.h b/include/net/sock.h
index 849c7df..2c7d60c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -426,7 +426,7 @@ static inline void sk_acceptq_added(stru
 
 static inline int sk_acceptq_is_full(struct sock *sk)
 {
-	return sk->sk_ack_backlog >= sk->sk_max_ack_backlog;
+	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
 }
 
 /*
