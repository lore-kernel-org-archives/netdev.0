From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/5] net: tcp: add flag for ca to indicate
 that ECN is required
Date: Mon, 22 Sep 2014 16:33:57 -0400 (EDT)
Message-ID: <20140922.163357.553905454314637491.davem@davemloft.net>
References: <1411248562-26581-1-git-send-email-fw@strlen.de>
	<1411248562-26581-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, lars@netapp.com, eric.dumazet@gmail.com,
	fontana@sharpeleven.org, hannes@stressinduktion.org,
	glenn.judd@morganstanley.com, dborkman@redhat.com,
	netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753576AbaIVUeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:34:00 -0400
In-Reply-To: <1411248562-26581-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 20 Sep 2014 23:29:19 +0200

> From: Daniel Borkmann <dborkman@redhat.com>
> 
> This patch adds a flag to TCP congestion algorithms that allows
> for requesting to mark IPv4/IPv6 sockets with transport as ECN
> capable, that is, ECT(0), when required by a congestion algorithm.
> 
> It is currently used and needed in DataCenter TCP (DCTCP), as it
> requires both peers to assert ECT on all IP packets sent - it
> uses ECN feedback (i.e. CE, Congestion Encountered information)
> from switches inside the data center to derive feedback to the
> end hosts.
> 
> Therefore, simply add a new flag to icsk_ca_ops. Note that DCTCP's
> algorithm/behaviour slightly diverges from RFC3168, therefore this
> is only (!) enabled iff the assigned congestion control ops module
> has requested this. By that, we can tightly couple this logic really
> only to the provided congestion control ops.
> 
> Joint work with Florian Westphal and Glenn Judd.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Glenn Judd <glenn.judd@morganstanley.com>

I don't think any administrator is going to be happy with this behavior.

If he explicitly sets the tcp_ecn sysctl to zero, and then an
unprivileged user can just start emitting ECN bits by selecting a
different congestion control algorithm, that is unexpected.

Please instead make datacenter TCP require ECN to be enabled.

Thanks.
