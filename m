From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] packet: Use symmetric hash for PACKET_FANOUT_HASH.
Date: Mon, 4 Jul 2016 11:29:33 +0200
Message-ID: <fb3d82e6-12c4-7caf-df13-51b75898fdc6@stressinduktion.org>
References: <20160701.160854.278188334806254498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eric@regit.org, victor@inliniac.net
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:35574 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753024AbcGDJ3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 05:29:36 -0400
In-Reply-To: <20160701.160854.278188334806254498.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.07.2016 22:08, David Miller wrote:
> 
> People who use PACKET_FANOUT_HASH want a symmetric hash, meaning that
> they want packets going in both directions on a flow to hash to the
> same bucket.
> 
> The core kernel SKB hash became non-symmetric when the ipv6 flow label
> and other entities were incorporated into the standard flow hash order
> to increase entropy.
> 
> But there are no users of PACKET_FANOUT_HASH who want an assymetric
> hash, they all want a symmetric one.
> 
> Therefore, use the flow dissector to compute a flat symmetric hash
> over only the protocol, addresses and ports.  This hash does not get
> installed into and override the normal skb hash, so this change has
> no effect whatsoever on the rest of the stack.
> 
> Reported-by: Eric Leblond <eric@regit.org>
> Tested-by: Eric Leblond <eric@regit.org>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> 
> I'll be pushing this to -stable branches as well.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Actually a funny trick I learned from DragonflyBSD sources is to just
randomize the first two bytes of the rss key and replicate them to fill
up the the last 38 bytes (or more). Doing so makes the rss hash
generation on the networking card symmetric [1].

Bye,
Hannes

[1]
http://gitweb.dragonflybsd.org/dragonfly.git/blob/HEAD:/sys/net/toeplitz.c#l41
