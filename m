From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_transmit_skb() optimizations
Date: Sat, 12 Oct 2013 01:06:05 -0400 (EDT)
Message-ID: <20131012.010605.1320162777840311015.davem@davemloft.net>
References: <20131011.174858.1461090000704613432.davem@davemloft.net>
	<1381531436.4971.114.camel@edumazet-glaptop.roam.corp.google.com>
	<1381540819.4971.117.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fitz@cs.yale.edu, ycheng@google.com,
	ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766Ab3JLFGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Oct 2013 01:06:08 -0400
In-Reply-To: <1381540819.4971.117.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 11 Oct 2013 18:20:19 -0700

> On Fri, 2013-10-11 at 15:43 -0700, Eric Dumazet wrote:
>> On Fri, 2013-10-11 at 17:48 -0400, David Miller wrote:
>> 
>> > This patch is correct, so I've applied it, but it points out a bug.
>> > 
>> > The __tcp_retransmit_skb() code that does a __pskb_copy() to handle
>> > NET_IP_ALIGN violations and skb_headroom() overflows is buggy because
>> > it needs to store a congestion control timestamp in the original 'skb'
>> > since that's what we'll look at in the retransmit queue.
>> 
>> Yes, I saw that, indeed.
>> 
>> I added it as low priority bug for the moment, as the default congestion
>> module do not really care, and this case is really unlikely ;)
>> 
> 
> Ah, I remember now that the conclusion was :
> the timestamp is not taken into account for retransmits.
> 
> ( FLAG_RETRANS_DATA_ACKED )

Great, thanks for the clarification.
