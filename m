From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] ipv4: try to cache dst_entries which would
 cause a redirect
Date: Mon, 26 Jan 2015 17:29:05 -0800 (PST)
Message-ID: <20150126.172905.2265431683987062613.davem@davemloft.net>
References: <996db187263dc0419ea3ab4d6e3fad4c0e0e5b44.1422010254.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg, mleitner@redhat.com,
	fw@strlen.de
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbbA0B3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 20:29:06 -0500
In-Reply-To: <996db187263dc0419ea3ab4d6e3fad4c0e0e5b44.1422010254.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 23 Jan 2015 12:01:26 +0100

> Not caching dst_entries which cause redirects could be exploited by hosts
> on the same subnet, causing a severe DoS attack. This effect aggravated
> since commit f88649721268999 ("ipv4: fix dst race in sk_dst_get()").
> 
> Lookups causing redirects will be allocated with DST_NOCACHE set which
> will force dst_release to free them via RCU.  Unfortunately waiting for
> RCU grace period just takes too long, we can end up with >1M dst_entries
> waiting to be released and the system will run OOM. rcuos threads cannot
> catch up under high softirq load.
> 
> Attaching the flag to emit a redirect later on to the specific skb allows
> us to cache those dst_entries thus reducing the pressure on allocation
> and deallocation.
> 
> This issue was discovered by Marcelo Leitner.
> 
> Cc: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Marcelo Leitner <mleitner@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
