From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: rfs: enable RFS before first data
 packet is received
Date: Thu, 16 Jun 2011 23:38:41 -0400 (EDT)
Message-ID: <20110616.233841.1893411919443027926.davem@davemloft.net>
References: <1308104128.4578.10.camel@edumazet-laptop>
	<1308268246.2925.37.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756214Ab1FQDis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:38:48 -0400
In-Reply-To: <1308268246.2925.37.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 17 Jun 2011 00:50:46 +0100

> On Wed, 2011-06-15 at 04:15 +0200, Eric Dumazet wrote:
>> @@ -1594,6 +1594,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
>>  			goto discard;
>>  
>>  		if (nsk != sk) {
>> +			sock_rps_save_rxhash(nsk, skb->rxhash);
>>  			if (tcp_child_process(sk, nsk, skb)) {
>>  				rsk = nsk;
>>  				goto reset;
>> 
> 
> I haven't tried this, but it looks reasonable to me.
> 
> What about IPv6?  The logic in tcp_v6_do_rcv() looks very similar.

Indeed ipv6 side needs the same fix.

Eric please add that part and resubmit.  And in fact I might stick
this into net-2.6 instead of net-next-2.6

Thanks!
