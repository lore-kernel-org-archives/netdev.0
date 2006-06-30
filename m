From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NETROM] Use socket helpers instead of direct fiddling with struct sock
Date: Fri, 30 Jun 2006 14:46:48 +0100
Message-ID: <20060630134648.GA12586@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:16614 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S932624AbWF3Nqu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 09:46:50 -0400
Received: from localhost.localdomain ([127.0.0.1]:59318 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S3686805AbWF3Nqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 14:46:49 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/netrom/af_netrom.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-net/net/netrom/af_netrom.c
===================================================================
--- linux-net.orig/net/netrom/af_netrom.c	2006-06-23 22:40:26.000000000 +0100
+++ linux-net/net/netrom/af_netrom.c	2006-06-23 22:43:14.000000000 +0100
@@ -801,7 +801,7 @@ static int nr_accept(struct socket *sock
 
 	/* Now attach up the new socket */
 	kfree_skb(skb);
-	sk->sk_ack_backlog--;
+	sk_acceptq_removed(sk);
 	newsock->sk = newsk;
 
 out:
@@ -986,7 +986,7 @@ int nr_rx_frame(struct sk_buff *skb, str
 	nr_make->vr        = 0;
 	nr_make->vl        = 0;
 	nr_make->state     = NR_STATE_3;
-	sk->sk_ack_backlog++;
+	sk_acceptq_added(sk);
 
 	nr_insert_socket(make);
 
