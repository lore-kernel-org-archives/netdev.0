From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [SOCK]: Adds a rcu_dereference() in sk_filter
Date: Tue, 08 Jan 2008 21:31:59 +0100
Message-ID: <4783DDBF.2040303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080005090205080508050802"
Cc: Linux Netdev List <netdev@vger.kernel.org>, dim@openvz.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46982 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754302AbYAHUcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 15:32:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080005090205080508050802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

It seems commit fda9ef5d679b07c9d9097aaf6ef7f069d794a8f9 introduced a RCU 
protection for sk_filter(), without a rcu_dereference()

Either we need a rcu_dereference(), either a comment should explain why we 
dont need it. I vote for the former.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------080005090205080508050802
Content-Type: text/plain;
 name="sk_filter.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sk_filter.patch"

diff --git a/include/net/sock.h b/include/net/sock.h
index 67e35c7..6e1542d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -944,7 +944,7 @@ static inline int sk_filter(struct sock *sk, struct sk_buff *skb)
 		return err;
 	
 	rcu_read_lock_bh();
-	filter = sk->sk_filter;
+	filter = rcu_dereference(sk->sk_filter);
 	if (filter) {
 		unsigned int pkt_len = sk_run_filter(skb, filter->insns,
 				filter->len);

--------------080005090205080508050802--
