From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Tue, 29 Oct 2013 22:33:31 -0400 (EDT)
Message-ID: <20131029.223331.1745589461091527596.davem@davemloft.net>
References: <20131029.220253.1263087684709722001.davem@davemloft.net>
	<20131030020543.GA1925@gondor.apana.org.au>
	<CAPshTCgykFMa=4rnQ3TKa2cfgWYj4TgByO2GbzLzq71Y_=oc=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	mwdalton@google.com
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab3J3Cdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 22:33:33 -0400
In-Reply-To: <CAPshTCgykFMa=4rnQ3TKa2cfgWYj4TgByO2GbzLzq71Y_=oc=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>
Date: Tue, 29 Oct 2013 19:13:50 -0700

> On Tue, Oct 29, 2013 at 7:05 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> On Tue, Oct 29, 2013 at 10:02:53PM -0400, David Miller wrote:
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: Tue, 29 Oct 2013 17:53:48 -0700
>>>
>>> > So should we apply the first fix to avoid the BUG_ON() ?
>>>
>>> Please be more specific, are you talking about splitting up
>>> this patch in some way?
>>
>> I think Eric is referring to the patch that removes the BUG_ON
>> in skb_segment and deals with the new mega-GRO packets.
>>
>> I think that's fine for stable, but for the long term we should
>> fix it properly as these new meag-GRO packets still retain the
>> existing packet boundaries and are trivially segmentable.
>>
>> If we are indeed able to do that, I doubt we would even need
>> the sysctl patch since the GRO performance should be vastly
>> superior to the non-GRO case, even for a router/bridge.
> 
> Probably not the case for the simple forwarding case. See my
> test result of some small (5-8%) CPU+throughput penalty from
> GRO (over GRE tunnel) posted previously. But I can believe
> the number may be very different if the forwarding path involves
> more work (NAT, iptables filtering,...,etc) resulting in a higher per
> pkt cost.

It's that way because it's not implemented properly.

GRO should always win, even on a router, because it decreases the
number of fundamental operations (routing lookups) that the stack
needs to perform.
