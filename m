From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/12] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Date: Thu, 14 Apr 2011 14:33:35 -0700 (PDT)
Message-ID: <20110414.143335.104052252.davem@davemloft.net>
References: <1302777698-28237-1-git-send-email-mgorman@suse.de>
	<1302777698-28237-9-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
To: mgorman@suse.de
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1302777698-28237-9-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 14 Apr 2011 11:41:34 +0100

> +extern int memalloc_socks;
> +static inline int sk_memalloc_socks(void)
> +{
> +	return memalloc_socks;
> +}
> +
 ...
> +static DEFINE_MUTEX(memalloc_socks_lock);
> +int memalloc_socks __read_mostly;

Please use an atomic_t, it has to be more efficient than this mutex
business.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
