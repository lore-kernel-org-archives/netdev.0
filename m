From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8 v3] net: Generalize checksum_init functions
Date: Wed, 30 Apr 2014 17:23:39 -0400 (EDT)
Message-ID: <20140430.172339.923016181378454751.davem@davemloft.net>
References: <alpine.DEB.2.02.1404290900390.9354@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933552AbaD3VXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 17:23:44 -0400
In-Reply-To: <alpine.DEB.2.02.1404290900390.9354@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 29 Apr 2014 09:18:47 -0700 (PDT)

> +	if (complete || skb->len <= 76)
> +		return __skb_checksum_complete(skb);

Undocumented constant '76', it has no meaning to me as a reviewer.

> +	if (!__skb_checksum_validate_unnecessary(skb, zero_okay, check))\
> +		__ret = __skb_checksum_validate_complete(skb,		\
> +				complete, compute_pseudo(skb, proto));	\

Please avoid double negatives.

This would read more clearly if it was something like:

	if (__skb_checksum_validate_needed(skb, zero_okay, check))
		__skb_checksum_validate_complete(...);
