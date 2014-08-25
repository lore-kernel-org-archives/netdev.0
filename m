From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Mon, 25 Aug 2014 15:41:24 -0700 (PDT)
Message-ID: <20140825.154124.2068819758570615886.davem@davemloft.net>
References: <CAHA+R7O_RSyKVNqcHXePbahvU+ayf77w61jos=G38M93okVWKw@mail.gmail.com>
	<20140825.153146.2165451041039058085.davem@davemloft.net>
	<1409006274.3173.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917AbaHYWlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:41:25 -0400
In-Reply-To: <1409006274.3173.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Aug 2014 15:37:54 -0700

> On Mon, 2014-08-25 at 15:31 -0700, David Miller wrote:
> 
>> It occurs to me that perhaps the thing to do is to pass sk_buff ** to
>> dev_hard_start_xmit().
> 
> This was my suggestion ;)
> 
> int ret = dev_hard_start_xmit(skb, dev, txq);
> 
> ->
> 
> int ret = dev_hard_start_xmit(&skb, dev, txq);

Ok and this can solve the GSO freeing issue too, if the caller was working
with a segmented SKB, he can pass &skb->next to dev_hard_start_xmit() then
if skb->next is NULL after dev_hard_start_xmit() returns we can free up
the head GSO skb.
