From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET is
 enabled
Date: Sun, 01 Nov 2015 15:58:59 -0500 (EST)
Message-ID: <20151101.155859.1206189858863918018.davem@davemloft.net>
References: <BN1PR0301MB07705F68B22ED84061E37337CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	<1446249142.6254.47.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446398459.6254.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, edumazet@google.com,
	netdev@vger.kernel.org, kys@microsoft.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbbKAU7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 15:59:02 -0500
In-Reply-To: <1446398459.6254.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 01 Nov 2015 09:20:59 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> My recent commit, attaching SYNACK messages to request sockets
> exposed a too small LL_MAX_HEADER when netvsc_drv.c is in use,
> because this driver sets a needed_headroom of 220 bytes.
> 
> Increase LL_MAX_HEADER in this case, to avoid a realloc of all
> TCP frames.
> 
> In another patch, I'll make skb_set_owner_w() more robust.
> 
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Bisected-by: Haiyang Zhang <haiyangz@microsoft.com>

Using a value of 256 just because HYPER-V is crazy imposes a huge
unnecessary burdon upon the rest of the stack.

I rejected a previous attempt to use such a huge value for
LL_MAX_HEADER, and I will do so again here.  We need a different fix
for this issue, one that doesn't hurt everyone.

Every distribution is going to turn all the options on, so you might
as well consider the largest LL_MAX_HEADER value the one %99.999
users end up paying the price for.
