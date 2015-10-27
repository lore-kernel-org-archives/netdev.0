From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2 1/4] ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked sockets
Date: Tue, 27 Oct 2015 16:02:12 +0100
Message-ID: <1445958135-19805-2-git-send-email-hannes@stressinduktion.org>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
Cc: edumazet@google.com, vyasevich@gmail.com, bcodding@redhat.com,
	tom@herbertland.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:46477 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932435AbbJ0PCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 11:02:24 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id CE24E215EB
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 11:02:23 -0400 (EDT)
In-Reply-To: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We cannot reliable calculate packet size on MSG_MORE corked sockets
and thus cannot decide if they are going to be fragmented later on,
so better not use CHECKSUM_PARTIAL in the first place.

Cc: Eric Dumazet <edumazet@google.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Benjamin Coddington <bcodding@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/ip_output.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 50e2973..0b02417 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -911,6 +911,7 @@ static int __ip_append_data(struct sock *sk,
 	if (transhdrlen &&
 	    length + fragheaderlen <= mtu &&
 	    rt->dst.dev->features & NETIF_F_V4_CSUM &&
+	    !(flags & MSG_MORE) &&
 	    !exthdrlen)
 		csummode = CHECKSUM_PARTIAL;
 
-- 
2.5.0
