From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: [PATCH v2 net-next] net: Add low-latency/polling support for UDP multicast
Date: Tue,  6 Aug 2013 14:51:03 -0500
Message-ID: <1375818663-12318-1-git-send-email-sbohrer@rgmadvisors.com>
References: <5200A203.2090306@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: eliezer.tamir@linux.intel.com, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>, tomk@rgmadvisors.com,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:60668 "EHLO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755729Ab3HFTvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 15:51:21 -0400
Received: by mail-ob0-f182.google.com with SMTP id wo10so1817781obc.41
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 12:51:21 -0700 (PDT)
In-Reply-To: <5200A203.2090306@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the napi id for each socket in the multicast path to enable
low-latency/polling support.

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
v2 include ipv6 support

 net/ipv4/udp.c |    1 +
 net/ipv6/udp.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 766e6ba..0d0da17 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1596,6 +1596,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	dif = skb->dev->ifindex;
 	sk = udp_v4_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
 	while (sk) {
+		sk_mark_napi_id(sk, skb);
 		stack[count++] = sk;
 		sk = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
 				       daddr, uh->source, saddr, dif);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f405815..82be372 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -756,6 +756,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	dif = inet6_iif(skb);
 	sk = udp_v6_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
 	while (sk) {
+		sk_mark_napi_id(sk, skb);
 		stack[count++] = sk;
 		sk = udp_v6_mcast_next(net, sk_nulls_next(sk), uh->dest, daddr,
 				       uh->source, saddr, dif);
-- 
1.7.7.6


-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
