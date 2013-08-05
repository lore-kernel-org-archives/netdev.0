From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: [PATCH net-next] net: Add low-latency/polling support for UDP multicast
Date: Mon,  5 Aug 2013 17:16:41 -0500
Message-ID: <1375741001-20553-1-git-send-email-sbohrer@rgmadvisors.com>
References: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: eliezer.tamir@linux.intel.com, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>, tomk@rgmadvisors.com,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:59715 "EHLO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755658Ab3HEWVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 18:21:42 -0400
Received: by mail-ob0-f170.google.com with SMTP id eh20so6874901obb.1
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 15:21:41 -0700 (PDT)
In-Reply-To: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the napi id for each socket in the multicast path to enable
low-latency/polling support.

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
 net/ipv4/udp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

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
-- 
1.7.7.6


-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
