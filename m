From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Wed, 8 Apr 2009 16:08:42 -0700
Message-ID: <20090408160842.6c2b1983@s6510>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47564 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756746AbZDHXJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2009 19:09:51 -0400
In-Reply-To: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Apr 2009 15:48:12 -0700
Tom Herbert <therbert@google.com> wrote:

> 	if (skb->protocol == __constant_htons(ETH_P_IP)) {
> +		struct iphdr *iph = (struct iphdr *)skb->data;
> +		__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
> +
> +		hash = 0;
> +		if (!(iph->frag_off &
> +		      __constant_htons(IP_MF|IP_OFFSET)) &&
> +		    ((iph->protocol == IPPROTO_TCP) ||
> +		     (iph->protocol == IPPROTO_UDP)))
> +			hash = ntohs(*layer4hdr ^ *(layer4hdr + 1));
> +
> +		hash ^= (ntohl(iph->saddr ^ iph->daddr)) & 0xffff;
> +		goto got_hash;

The hash could should be same as existing Tx hash?

What about using hardware RSS values?
