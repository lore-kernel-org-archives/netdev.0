From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: Skip XFRM lookup if dst_entry in socket
 cache is valid
Date: Wed, 08 Jun 2016 11:16:51 -0700 (PDT)
Message-ID: <20160608.111651.567746976064784585.davem@davemloft.net>
References: <1465391614-8961-1-git-send-email-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jtluka@redhat.com,
	hannes@stressinduktion.org
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526AbcFHSQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 14:16:53 -0400
In-Reply-To: <1465391614-8961-1-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Wed,  8 Jun 2016 15:13:34 +0200

> At present we perform an xfrm_lookup() for each UDPv6 message we
> send. The lookup involves querying the flow cache (flow_cache_lookup)
> and, in case of a cache miss, creating an XFRM bundle.
> 
> If we miss the flow cache, we can end up creating a new bundle and
> deriving the path MTU (xfrm_init_pmtu) from on an already transformed
> dst_entry, which we pass from the socket cache (sk->sk_dst_cache) down
> to xfrm_lookup(). This can happen only if we're caching the dst_entry
> in the socket, that is when we're using a connected UDP socket.
> 
> To put it another way, the path MTU shrinks each time we miss the flow
> cache, which later on leads to incorrectly fragmented payload. It can
> be observed with ESPv6 in transport mode:
 ...
> To prevent the recreation of an XFRM bundle, avoid an XFRM lookup
> altogether whenever we already have a destination entry cached in the
> socket. This prevents the path MTU shrinkage and brings us on par with
> UDPv4.
> 
> The fix also benefits connected PINGv6 sockets, another user of
> ip6_sk_dst_lookup_flow(), who also suffer messages being transformed
> twice.
> 
> Joint work with Hannes Frederic Sowa.
> 
> Reported-by: Jan Tluka <jtluka@redhat.com>
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
