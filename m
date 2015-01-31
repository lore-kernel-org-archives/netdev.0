From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 03/18] rawv6_send_hdrinc(): pass msghdr
Date: Sat, 31 Jan 2015 03:56:29 +0000
Message-ID: <1422676604-18533-3-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54985 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756473AbbAaD4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 22:56:45 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/ipv6/raw.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ee25631..0dbb328 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -609,7 +609,7 @@ out:
 	return err;
 }
 
-static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
+static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 			struct flowi6 *fl6, struct dst_entry **dstp,
 			unsigned int flags)
 {
@@ -648,7 +648,7 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	skb->ip_summed = CHECKSUM_NONE;
 
 	skb->transport_header = skb->network_header;
-	err = memcpy_fromiovecend((void *)iph, from, 0, length);
+	err = memcpy_fromiovecend((void *)iph, msg->msg_iter.iov, 0, length);
 	if (err)
 		goto error_fault;
 
@@ -886,8 +886,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 back_from_confirm:
 	if (inet->hdrincl)
-		/* XXX: stripping const */
-		err = rawv6_send_hdrinc(sk, (struct iovec *)msg->msg_iter.iov, len, &fl6, &dst, msg->msg_flags);
+		err = rawv6_send_hdrinc(sk, msg, len, &fl6, &dst, msg->msg_flags);
 	else {
 		lock_sock(sk);
 		err = ip6_append_data(sk, raw6_getfrag, &rfv,
-- 
2.1.4
