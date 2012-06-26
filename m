From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Mon, 25 Jun 2012 21:55:37 -0700 (PDT)
Message-ID: <20120625.215537.169465424900682764.davem@davemloft.net>
References: <1340440962.17495.39.camel@edumazet-glaptop>
	<20120625.154340.158890441165257041.davem@davemloft.net>
	<1340686296.10893.115.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, dave.taht@gmail.com,
	hans.schillstrom@ericsson.com, netdev@vger.kernel.org,
	ncardwell@google.com, therbert@google.com, brouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58252 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501Ab2FZEzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 00:55:40 -0400
In-Reply-To: <1340686296.10893.115.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Jun 2012 06:51:36 +0200

> On Mon, 2012-06-25 at 15:43 -0700, David Miller wrote:
> 
>> I don't agree with this change.
>> 
>> What is the point in having real classification configuration if
>> arbitrary places in the network stack are going to override SKB
>> priority with a fixed priority setting?
>> 
>> I bet the person who set listening socket priority really meant it and
>> does not expect you to override it.
> 
> 
> If I add a test on listener_sk->sk_priority being 0, would you accept
> the patch ? If classification is done after tcp stack, it wont be hurt
> by initial skb priority ?

It's better than your original patch, but it suffers from the same
fundamental problem.

No user is going to expect that TCP on it's own has choosen a
non-default priority and only for some packet types.  It's completely
unexpected behavior.

A SYN flood consumes so much more RX work than the TX for the SYNACK's
ever can.

So whilst I understand your desire to handle all elements of this kind
of attack, this one is reaching too far.
