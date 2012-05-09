From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] netfilter updates for net-next (upcoming 3.5),
 batch 2
Date: Wed, 09 May 2012 18:11:19 -0400 (EDT)
Message-ID: <20120509.181119.549113304045405166.davem@davemloft.net>
References: <1336563188-6720-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932487Ab2EIWMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 18:12:31 -0400
In-Reply-To: <1336563188-6720-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Wed,  9 May 2012 13:33:03 +0200

> This is a second batch of netfilter updates for net-next, they contain:
> 
> * The new HMARK target from Hans Schillstrom. It took lots of spins
>   to get this into shape. This target provides a hash-based packet / flow
>   pre-classifier for iptables that can be used to distribute packets
>   / flows between uplinks and backend servers. It provides to modes, one
>   that relies on conntrack, and one that is stateless per-packet.
> 
> * Byte-based cost calculation for the hashlimit match, to detect when
>   a host consumes more bandwidth than expected. This patch from Florian
>   Westphal.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/net-next

Pulled.

Two suggested improvements:

1) The HMARK hash is quite expensive, because it uses a modulus.

   Consider adjusting it to use the usual trick:

	((u64)(HASH_VAL * HASH_SIZE)) >> 32

   so that this can be a multiply instead of a modulus.

2) XT_HASHLIMIT_MAX is cumbersome.

   The canonical way to validate if the set bits are in	a
   valid range is to have a "_ALL" macro, and test:

	if (val & ~XT_HASHLIMIT_ALL)
		goto err;

   or similar.

Thanks.
