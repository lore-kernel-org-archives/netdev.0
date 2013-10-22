From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netpoll: linearize skb before accessing its data
Date: Tue, 22 Oct 2013 02:25:25 -0400 (EDT)
Message-ID: <20131022.022525.2068838304168924147.davem@davemloft.net>
References: <1382391080-1607-1-git-send-email-antonio@meshcoding.com>
	<20131021.182319.625146263287554088.davem@davemloft.net>
	<20131022060635.GF1544@neomailbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090Ab3JVGZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 02:25:26 -0400
In-Reply-To: <20131022060635.GF1544@neomailbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Tue, 22 Oct 2013 08:06:35 +0200

> But rx_hook() does not receive any skb:
> 
> 609                 np->rx_hook(np, ntohs(uh->source),
> 610                                (char *)(uh+1),
> 611                                ulen - sizeof(struct udphdr));
> 
> it just receives a pointer to the data and can't do anything to make it linear.
> (uh is a pointer to the udp header). Am I missing something?

Then this hook's API needs to be fixed, it's completely broken.

Make it pass the SKB and the appropriate offset (from skb->data) in
bytes.
