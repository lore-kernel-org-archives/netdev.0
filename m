From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] macvlan: fix oops with vlan-on-top and HW_VLAN_CTAG_TX
 lowerdev
Date: Fri, 3 Jan 2014 12:39:04 +0100
Message-ID: <20140103113904.GB28854@breakpoint.cc>
References: <1388237920-5140-1-git-send-email-fw@strlen.de>
 <20131229.170121.154913581019152817.davem@davemloft.net>
 <20131230102712.GO29632@breakpoint.cc>
 <20131231.162448.1656983197554902144.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43079 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751085AbaACLjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 06:39:07 -0500
Content-Disposition: inline
In-Reply-To: <20131231.162448.1656983197554902144.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> vlan: Fix header ops passthru when doing TX VLAN offload.
> 
> When the vlan code detects that the real device can do TX VLAN offloads
> in hardware, it tries to arrange for the real device's header_ops to
> be invoked directly.

Sorry for the late reply.

> +static inline int dev_rebuild_header(struct sk_buff *skb)
> +{
> +	const struct net_device *dev = skb->dev;
> +
> +	if (!dev->header_ops || !dev->header_ops->rebuild)
> +		return 0;
> +	return dev->header_ops->rebuild(skb);
> +}
> +
[..]

> +static const struct header_ops vlan_passthru_header_ops = {
> +	.create	 = vlan_passthru_hard_header,
> +	.rebuild = dev_rebuild_header,

Doesn't that result in infinite recursion when invoking
dev_rebuild_header() on skb whose dev->header_ops is
vlan_passthru_header_ops?
