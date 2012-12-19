From: David Miller <davem@davemloft.net>
Subject: Re: TCP delayed ACK heuristic
Date: Wed, 19 Dec 2012 12:59:39 -0800 (PST)
Message-ID: <20121219.125939.1674292599518627751.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B70F4@saturn3.aculab.com>
	<1355900436.6665.16.camel@cr0>
	<50D209E9.2000504@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	greearb@candelatech.com, eric.dumazet@gmail.com,
	shemminger@vyatta.com, tgraf@redhat.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819Ab2LSU7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 15:59:40 -0500
In-Reply-To: <50D209E9.2000504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 19 Dec 2012 10:39:37 -0800

> On 12/18/2012 11:00 PM, Cong Wang wrote:
>> On Tue, 2012-12-18 at 16:39 +0000, David Laight wrote:
>>> There are problems with only implementing the acks
>>> specified by RFC1122.
>>
>> Yeah, the problem is if we can violate this RFC for getting better
>> performance. Or it is just a no-no?
>>
>> Although RFC 2525 mentions this as "Stretch ACK Violation", I am still
>> not sure if that means we can violate RFC1122 legally.
> 
> The term used in RFC1122 is "SHOULD" not "MUST."  Same for RFC2525
> when it talks about "Stretch ACK Violation."  A TCP stack may have
> behaviour which differs from a SHOULD so long as there is a reasonable
> reason for it.

Yes, but RFC2525 makes it very clear why we should not even
consider doing crap like this.

ACKs are the only information we have to detect loss.

And, for the same reasons that TCP VEGAS is fundamentally broken, we
cannot measure the pipe or some other receiver-side-visible piece of
information to determine when it's "safe" to stretch ACK.

And even if it's "safe", we should not do it so that losses are
accurately detected and we don't spuriously retransmit.

The only way to know when the bandwidth increases is to "test" it, by
sending more and more packets until drops happen.  That's why all
successful congestion control algorithms must operate on explicited
tested pieces of information.

Similarly, it's not really possible to universally know if it's safe
to stretch ACK or not.

Can we please drop this idea?  It has zero value and all downside as
far as I'm concerned.

Thanks.
