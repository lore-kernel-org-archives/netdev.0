From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: Count in extension headers in
 skb->network_header
Date: Thu, 07 Apr 2016 22:44:55 -0400 (EDT)
Message-ID: <20160407.224455.695892175098979019.davem@davemloft.net>
References: <4697d0324d0b4313cbc2053b49ac85ec955b81cb.1459872592.git.jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiji@redhat.com, hannes@stressinduktion.org
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbcDHCo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 22:44:59 -0400
In-Reply-To: <4697d0324d0b4313cbc2053b49ac85ec955b81cb.1459872592.git.jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Tue,  5 Apr 2016 18:41:08 +0200

> When sending a UDPv6 message longer than MTU, account for the length
> of fragmentable IPv6 extension headers in skb->network_header offset.
> Same as we do in alloc_new_skb path in __ip6_append_data().
> 
> This ensures that later on __ip6_make_skb() will make space in
> headroom for fragmentable extension headers:
> 
> 	/* move skb->data to ip header from ext header */
> 	if (skb->data < skb_network_header(skb))
> 		__skb_pull(skb, skb_network_offset(skb));
> 
> Prevents a splat due to skb_under_panic:
 ...
> Reported-by: Ji Jianwen <jiji@redhat.com>
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
