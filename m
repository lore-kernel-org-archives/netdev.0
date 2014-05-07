From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: send pkttoobig immediately if orig frag
 size > mtu
Date: Wed, 07 May 2014 15:28:29 -0400 (EDT)
Message-ID: <20140507.152829.1489444818446628583.davem@davemloft.net>
References: <1399241014-32471-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51071 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbaEGT2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 15:28:30 -0400
In-Reply-To: <1399241014-32471-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon,  5 May 2014 00:03:34 +0200

> If conntrack defragments incoming ipv6 frags it stores largest original
> frag size in ip6cb and sets ->local_df.
> 
> We must thus first test the largest original frag size vs. mtu, and not
> vice versa.
> 
> Without this patch PKTTOOBIG is still generated in ip6_fragment() later
> in the stack, but
> 
> 1) IPSTATS_MIB_INTOOBIGERRORS won't increment
> 2) packet did (needlessly) traverse netfilter postrouting hook.
> 
> Fixes: fe6cc55f3a9 ("net: ip, ipv6: handle gso skbs in forwarding path")
> Signed-off-by: Florian Westphal <fw@strlen.de>

Also applied and queued up for -stable, thanks Florian.
