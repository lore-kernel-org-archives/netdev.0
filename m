From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Cache route in IP tunnels
Date: Thu, 12 Dec 2013 12:29:56 -0800
Message-ID: <1386880196.19078.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1312112207400.27914@tomh.mtv.corp.google.com>
	 <1386833838.19078.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131212.135433.87781160683841713.davem@davemloft.net>
	 <CA+mtBx9GNG3XuyczBAJT4o2FnRBbHTV5U6PYnAJA1gf84ExeNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:54474 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab3LLU37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 15:29:59 -0500
Received: by mail-yh0-f49.google.com with SMTP id z20so795313yhz.36
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 12:29:59 -0800 (PST)
In-Reply-To: <CA+mtBx9GNG3XuyczBAJT4o2FnRBbHTV5U6PYnAJA1gf84ExeNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-12 at 12:19 -0800, Tom Herbert wrote:

> btw, I needed to disable gro on the tun interface. With it enabled,
> performance in TCP_RR is abysmal. Looking into that.

This is a known problem.

Given that Jerry is working on GRO I was not really wanting to fix
this...

Thats a basically revert of
( http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=693019e90ca45d881109d32c0c6d29adf03f6447 ) 

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 42ffbc8d65c6..dc7de784e934 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -111,7 +111,6 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
 		skb->rxhash = 0;
 	skb_dst_drop(skb);
 	skb->vlan_tci = 0;
-	skb_set_queue_mapping(skb, 0);
 	skb->pkt_type = PACKET_HOST;
 	return 0;
 }
