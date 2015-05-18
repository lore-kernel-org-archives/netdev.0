From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when
 forwarding
Date: Mon, 18 May 2015 15:39:22 -0400 (EDT)
Message-ID: <20150518.153922.1873846748456446294.davem@davemloft.net>
References: <1431032664-6478-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	edumazet@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556AbbERTj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 15:39:26 -0400
In-Reply-To: <1431032664-6478-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu,  7 May 2015 23:04:24 +0200

> There was interest in keeping geometry of original fragments on forward.
> 
> This (re)enables this feature.
> 
> on router with mtu 1500 on all interfaces and netfilter conntrack enabled:
 ...
> Caveat:
> This disables the optimization made in commit
> 3cc4949269e01f39443d0 ("ipv4: use skb coalescing in defragmentation") for
> everyone as soon as nf_defrag_ipv4 modules are loaded (conntrack defrag
> hooks earlier than ipv4 stacks own defragmentation for local delivery),
> and there is no way to easily determine if we will forward the skb at that
> stage.
> 
> ip_fragment checks the size of the frag skbs vs. the outgoing device mtu
> before using them so if device mtu is smaller than the frag skb length
> the device mtu will be used instead for refragmentation.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Indeed, I agree that we should only modify the packet's geomtry if we
know it's to be locally delivered.

But paying the cost just because a netfilter module is loaded, that's
really heavy handed and shows really bad engineering on our part.

When I hear "happens when netfilter modules are loaded", it translates
into my head as "all the time".  And for you it should too, because
effectively that's how the world operates.
