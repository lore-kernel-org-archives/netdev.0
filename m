From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net 3/3] openvswitch: Fix skb leak using IPv6 defrag
Date: Tue, 27 Oct 2015 19:32:59 -0700 (PDT)
Message-ID: <20151027.193259.1057135403867772523.davem@davemloft.net>
References: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
	<1445829710-11292-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, pablo@netfilter.org,
	azhou@nicira.com
To: joestringer@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754908AbbJ1CQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:16:18 -0400
In-Reply-To: <1445829710-11292-3-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>
Date: Sun, 25 Oct 2015 20:21:50 -0700

> nf_ct_frag6_gather() makes a clone of each skb passed to it, and if the
> reassembly is successful, expects the caller to free all of the original
> skbs using nf_ct_frag6_consume_orig(). This call was previously missing,
> meaning that the original fragments were never freed (with the exception
> of the last fragment to arrive).
> 
> Fix this by ensuring that all original fragments except for the last
> fragment are freed via nf_ct_frag6_consume_orig(). The last fragment
> will be morphed into the head, so it must not be freed yet. Furthermore,
> retain the ->next pointer for the head after skb_morph().
> 
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Reported-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Applied.
