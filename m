From: Tom Herbert <therbert@google.com>
Subject: [PATCH] ipv6: Need to sock_put on zero csum error
Date: Mon, 5 May 2014 13:11:57 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405051309280.21835@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:51509 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbaEEUL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 16:11:58 -0400
Received: by mail-yh0-f74.google.com with SMTP id a41so318537yho.1
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 13:11:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4068579e1e098fa81d48db9ba4432ab664c58561 introduced
zero checksums being allowed for IPv6, but in the case that a
socket disallows a zero checksum we need to sock_put.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/udp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4fcd9bc..fc2be63 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -884,6 +884,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		int ret;
 
 		if (!uh->check && !sk->sk_no_check) {
+			sock_put(sk);
 			udp6_csum_zero_error(skb);
 			goto csum_error;
 		}
-- 
1.9.1.423.g4596e3a
