From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: sched: use counter to break reclassify loops
Date: Wed, 13 May 2015 15:08:32 -0400 (EDT)
Message-ID: <20150513.150832.2189582687167426737.davem@davemloft.net>
References: <1431366641-24735-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934590AbbEMTK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 15:10:26 -0400
In-Reply-To: <1431366641-24735-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 11 May 2015 19:50:41 +0200

> Seems all we want here is to avoid endless 'goto reclassify' loop.
> tc_classify_compat even resets this counter when something other
> than TC_ACT_RECLASSIFY is returned, so this skb-counter doesn't
> break hypothetical loops induced by something other than perpetual
> TC_ACT_RECLASSIFY return values.
> 
> skb_act_clone is now identical to skb_clone, so just use that.
> 
> Tested with following (bogus) filter:
> tc filter add dev eth0 parent ffff: \
>  protocol ip u32 match u32 0 0 police rate 10Kbit burst \
>  64000 mtu 1500 action reclassify
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks everyone.
