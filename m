From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next 1/2] qdisc:  Allow qdiscs to provide backpressure up
 the stack.
Date: Wed, 25 Aug 2010 13:56:42 -0700
Message-ID: <4C75838A.2080304@candelatech.com>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com> <20100825134452.5aac9dfb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56488 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab0HYU4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 16:56:42 -0400
In-Reply-To: <20100825134452.5aac9dfb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2010 01:44 PM, Stephen Hemminger wrote:
> On Wed, 25 Aug 2010 12:00:50 -0700

>>   struct Qdisc {
>>   	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
>> +	int 			(*try_enqueue)(struct sk_buff *, struct Qdisc *dev); /* May return NET_XMIT_BUSY and NOT free skb. */
>>
>
>
> There aren't that many qdisc modules; just fix them all and change
> semantics of enqueue.  How do you expect to handle the retry? Spinning
> at the higher level is a bad idea and there is no non-racy way to get
> a callback to make forward progress.

It may only make sense for things like macvlan at this point, since
it is already valid to return NET_XMIT_BUSY and not free the SKB
when you call dev->hard_start_xmit().

Using the try_ logic for sockets and such would probably require a good
deal more work, and probably is something I'd not attempt any time
soon (there are others who know that code better, so maybe they'd
be able & willing to do that work).

If/when all the calling code knows how to do the retry logic properly,
then we could have a single enqueue method, but I think to allow
incremental changes, it's best to have the two methods for now.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

