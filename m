From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [RFC][PATCH 3/4] deadlock prevention core
Date: Sat, 12 Aug 2006 19:31:02 +0200 (CEST)
Message-ID: <44640.81.207.0.53.1155403862.squirrel@81.207.0.53>
References: <20060812141415.30842.78695.sendpatchset@lappy>
    <20060812141445.30842.47336.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "Peter Zijlstra" <a.p.zijlstra@chello.nl>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Daniel Phillips" <phillips@google.com>,
	"Rik van Riel" <riel@redhat.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helium.samage.net ([83.149.67.129]:30897 "EHLO
	helium.samage.net") by vger.kernel.org with ESMTP id S964926AbWHLRbP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 13:31:15 -0400
In-Reply-To: <20060812141445.30842.47336.sendpatchset@lappy>
To: "Peter Zijlstra" <a.p.zijlstra@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, August 12, 2006 16:14, Peter Zijlstra said:
> +struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask, int fclone)
> +{
> +	struct sk_buff *skb;
> +
> +	skb = ___alloc_skb(size, gfp_mask & ~__GFP_MEMALLOC, fclone);
> +
> +	if (!skb && (gfp_mask & __GFP_MEMALLOC) && memalloc_skbs_available())
> +		skb = ___alloc_skb(size, gfp_mask, fclone);
> +
> +	return skb;
> +}
> +

I'd drop the memalloc_skbs_available() check, as that's already done by
___alloc_skb.

> +static DEFINE_SPINLOCK(memalloc_lock);
> +static int memalloc_socks;
> +static unsigned long memalloc_reserve;

Why is this a long? adjust_memalloc_reserve() takes an int.
Is it needed at all, considering var_free_kbytes already exists?

Greetings,

Indan


