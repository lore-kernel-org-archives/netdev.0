From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix possible wrong checksum generation.
Date: Wed, 13 Feb 2013 13:31:07 -0500 (EST)
Message-ID: <20130213.133107.1252368625820641730.davem@davemloft.net>
References: <1360610861-1753-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, jesse@nicira.com,
	bhutchings@solarflare.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195Ab3BMSbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 13:31:09 -0500
In-Reply-To: <1360610861-1753-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Mon, 11 Feb 2013 11:27:41 -0800

> Patch cef401de7be8c4e (net: fix possible wrong checksum
> generation) fixed wrong checksum calculation but it broke TSO by
> defining new GSO type but not a netdev feature for that type.
> net_gso_ok() would not allow hardware checksum/segmentation
> offload of such packets without the feature.
> 
> Following patch fixes TSO and wrong checksum. This patch uses
> same logic that Eric Dumazet used. Patch introduces new flag
> SKBTX_SHARED_FRAG if at least one frag can be modified by
> the user. but SKBTX_SHARED_FRAG flag is kept in skb shared
> info tx_flags rather than gso_type.
> 
> tx_flags is better compared to gso_type since we can have skb with
> shared frag without gso packet. It does not link SHARED_FRAG to
> GSO, So there is no need to define netdev feature for this.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.
