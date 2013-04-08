From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 16:44:39 -0400 (EDT)
Message-ID: <20130408.164439.2282891058177074789.davem@davemloft.net>
References: <1365445303.3887.33.camel@edumazet-glaptop>
	<1365445825.3887.35.camel@edumazet-glaptop>
	<3294227.D2rod7xgQB@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, mvadkert@redhat.com
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514Ab3DHUol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 16:44:41 -0400
In-Reply-To: <3294227.D2rod7xgQB@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Mon, 08 Apr 2013 16:37:22 -0400

> On Monday, April 08, 2013 11:30:25 AM Eric Dumazet wrote:
>> On Mon, 2013-04-08 at 11:21 -0700, Eric Dumazet wrote:
>> > On Mon, 2013-04-08 at 14:12 -0400, Paul Moore wrote:
>> > > It seems a bit fragile to me, perhaps even hacky, but in some ways I
>> > > guess it isn't anymore fragile than relying on skb->sk - as this
>> > > problem demonstrates. My other concern is that adding this hook
>> > > *correctly* is likely to touch a lot of files and may be a bit much so
>> > > late in the 3.9 cycle, Dave, what say you?> 
>> > I don't get it, 90ba9b1986b5ac4b2d18 was in 3.6, why do you care of
>> > 3.9 ?
>> > 
>> > I am preparing a fix right now. Not a revert, thank you.
>> 
>> Is the following patch not good enough ?
> 
> I think it is somewhat telling that the hook you're proposing doesn't ever 
> make any calls into any of the individual LSMs, it only calls back into the 
> networking stack.  In my mind, this makes it an abuse of the LSM mechanism.

Without LSMs the socket reference is spurious and pointless overhead,
therefore the only acceptable fix one which only takes the socket
reference when there are LSMs with a need.
