From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/9] udp: make local function static
Date: Fri, 19 May 2017 09:55:50 -0700
Message-ID: <20170519165556.483-4-sthemmin@microsoft.com>
References: <20170519165556.483-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35144 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753619AbdESQ4I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:56:08 -0400
Received: by mail-pf0-f177.google.com with SMTP id n23so42445577pfb.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:56:07 -0700 (PDT)
In-Reply-To: <20170519165556.483-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udp_queue_rcv_skb was global but only used in one file.
Identified by this warning:
net/ipv4/udp.c:1775:5: warning: no previous prototype for ‘udp_queue_rcv_skb’ [-Wmissing-prototypes]
 int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/ipv4/udp.c | 2 +-
 net/ipv6/udp.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e7b6cfcca627..8d7980ca27a0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1772,7 +1772,7 @@ EXPORT_SYMBOL(udp_encap_enable);
  * Note that in the success and error cases, the skb is assumed to
  * have either been requeued or freed.
  */
-int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int is_udplite = IS_UDPLITE(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f78fdf8c9f0f..d558c1fef6fd 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -570,7 +570,7 @@ void udpv6_encap_enable(void)
 }
 EXPORT_SYMBOL(udpv6_encap_enable);
 
-int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int is_udplite = IS_UDPLITE(sk);
-- 
2.11.0
