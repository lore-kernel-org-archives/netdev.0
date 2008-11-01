From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH 2/2] udp: Fix the SNMP counter of UDP_MIB_INERRORS
Date: Sat, 01 Nov 2008 17:17:36 +0800
Message-ID: <490C1EB0.9030709@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62394 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751170AbYKAJVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Nov 2008 05:21:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP packets received in udpv6_recvmsg() are not only IPv6 UDP packets, but
also have IPv4 UDP packets, so when do the counter of UDP_MIB_INERRORS in
udpv6_recvmsg(), we should check whether the packet is a IPv6 UDP packet
or a IPv4 UDP packet.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv6/udp.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1a63809..2f918a0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -236,8 +236,14 @@ out:
 
 csum_copy_err:
 	lock_sock(sk);
-	if (!skb_kill_datagram(sk, skb, flags))
-		UDP6_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+	if (!skb_kill_datagram(sk, skb, flags)) {
+		if (is_udp4)
+			UDP_INC_STATS_USER(sock_net(sk),
+					UDP_MIB_INERRORS, is_udplite);
+		else
+			UDP6_INC_STATS_USER(sock_net(sk),
+					UDP_MIB_INERRORS, is_udplite);
+	}
 	release_sock(sk);
 
 	if (flags & MSG_DONTWAIT)
-- 
1.5.3.8



