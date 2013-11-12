From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: fix netlink_ack with large messages
Date: Tue, 12 Nov 2013 14:35:15 -0500 (EST)
Message-ID: <20131112.143515.1092879587357986857.davem@davemloft.net>
References: <527E3C17.1080508@mojatatu.com>
	<20131109180353.GA3715@localhost>
	<20131112162907.50f0bafa@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, jhs@mojatatu.com, tgraf@suug.ch,
	netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194Ab3KLTfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 14:35:18 -0500
In-Reply-To: <20131112162907.50f0bafa@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 12 Nov 2013 16:29:07 +0100

> On Sat, 9 Nov 2013 19:03:53 +0100, Pablo Neira Ayuso wrote:
>> On Sat, Nov 09, 2013 at 08:43:51AM -0500, Jamal Hadi Salim wrote:
>> > for errors, we need to give the user something back. This has been the
>> > behavior for 80 years now. Giving them a HUGE message
>> > back is rediculuos(tm). Ive had enough of SCTP doing that.
>> > We need to cap it - sort of what ICMP does.
>> > ICMP caps at 64B; something like 128B is reasonable.
>> 
>> Personally, I have only used the sequence number to correlate the
>> original request with the ack reply, so I agree in that trimming it to
>> some reasonable amount of bytes like ICMP is the way to go. I prefer
>> if we select a large enough amount of bytes to avoid breaking backward
>> compatibility, eg. 128KB, since I'm not sure what kind of handling
>> others may have done of this.
> 
> Do you think capping at NLMSG_GOODSIZE would be too low? The allocation
> won't fit into one page with NLMSG_GOODSIZE but I doubt we can go lower
> than that. Alternatively, we can do some math to fully use the two
> pages, like
> 	NLMSG_GOODSIZE + min(PAGE_SIZE, 8192UL) - NLMSG_HDRLEN - NLMSG_ALIGN(sizeof(struct nlmsgerr))
> (which I'm not sure is worth it).

I don't think this is the way to go.

I think since existing apps expect the whole message, we have to
provide it.

We should add a new socket option so that applications can ask that
messages not be quoted in ACKs, as I've stated a few times already in
this thread.
