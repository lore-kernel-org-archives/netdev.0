From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] tun: dont force inline of functions
Date: Wed, 08 Jun 2011 17:33:08 -0700
Message-ID: <20110609003321.965291152@vyatta.com>
References: <20110609003306.651532958@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523Ab1FIBQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 21:16:29 -0400
Content-Disposition: inline; filename=tun-tap-noinline.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current standard practice is to not mark most functions as inline
and  let compiler decide instead.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tun.c	2011-05-13 16:43:25.643040523 -0700
+++ b/drivers/net/tun.c	2011-05-13 16:47:06.041228664 -0700
@@ -550,9 +550,9 @@ static unsigned int tun_chr_poll(struct
 
 /* prepad is the amount to reserve at front.  len is length after that.
  * linear is a hint as to how much to copy (usually headers). */
-static inline struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
-					    size_t prepad, size_t len,
-					    size_t linear, int noblock)
+static struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
+				     size_t prepad, size_t len,
+				     size_t linear, int noblock)
 {
 	struct sock *sk = tun->socket.sk;
 	struct sk_buff *skb;
@@ -578,9 +578,9 @@ static inline struct sk_buff *tun_alloc_
 }
 
 /* Get packet from user space buffer */
-static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
-				       const struct iovec *iv, size_t count,
-				       int noblock)
+static ssize_t tun_get_user(struct tun_struct *tun,
+			    const struct iovec *iv, size_t count,
+			    int noblock)
 {
 	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
 	struct sk_buff *skb;
@@ -729,9 +729,9 @@ static ssize_t tun_chr_aio_write(struct
 }
 
 /* Put packet to the user space buffer */
-static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
-				       struct sk_buff *skb,
-				       const struct iovec *iv, int len)
+static ssize_t tun_put_user(struct tun_struct *tun,
+			    struct sk_buff *skb,
+			    const struct iovec *iv, int len)
 {
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total = 0;


