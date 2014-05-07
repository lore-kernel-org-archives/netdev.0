From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: ip_forward: fix inverted local_df test
Date: Wed, 07 May 2014 15:26:47 -0400 (EDT)
Message-ID: <20140507.152647.350304258692008227.davem@davemloft.net>
References: <1399238671-21170-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51064 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbaEGT0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 15:26:49 -0400
In-Reply-To: <1399238671-21170-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun,  4 May 2014 23:24:31 +0200

> local_df means 'ignore DF bit if set', so if its set we're
> allowed to perform ip fragmentation.
> 
> This wasn't noticed earlier because the output path also drops such skbs
> (and emits needed icmp error) and because netfilter ip defrag did not
> set local_df until couple of days ago.
> 
> Only difference is that DF-packets-larger-than MTU now discarded
> earlier (f.e. we avoid pointless netfilter postrouting trip).
> 
> While at it, drop the repeated test ip_exceeds_mtu, checking it once
> is enough...
> 
> Fixes: fe6cc55f3a9 ("net: ip, ipv6: handle gso skbs in forwarding path")
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied and queued up for -stable, thanks Florian.
