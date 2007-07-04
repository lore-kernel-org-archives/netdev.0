From: Patrick McHardy <kaber@trash.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Wed, 04 Jul 2007 16:48:07 +0200
Message-ID: <468BB327.5050709@trash.net>
References: <1183492286.4021.21.camel@johannes.berg>	 <468BAADC.4030203@trash.net> <1183558702.3812.33.camel@johannes.berg>	 <468BAF10.6080208@trash.net> <1183559883.3812.42.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39179 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758262AbXGDOtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 10:49:14 -0400
In-Reply-To: <1183559883.3812.42.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Wed, 2007-07-04 at 16:30 +0200, Patrick McHardy wrote:
> 
>>I wonder if thats really a good idea to use multicast for device
>>configuration. Unicast transmissions from userspace to kernel
>>are reliable when you don't use MSG_DONTWAIT. For multicasts
>>doing the same would mean blocking on each receiver when the
>>receive queue is full.
> 
> 
> That's a good point actually. Are transmissions from userspace to
> userspace also reliable in that case?


Yes, although in both cases you have no guarantee how long its
going to take, someone else could be flooding the receive queue.
For userspace this is more likely to be a real problem though
since the kernel will keep processing the queue as long as packets
are in it, while userspace could be scheduled away.

> In fact, we haven't quite decided yet whether we want all configuration
> to be via netlink. I strongly prefer this, but other people say that
> userspace<->userspace communication is nothing that nl80211 should be
> involved in.


I'm not so sure myself whether netlink is really a good idea for
userspace<->userspace communication because of the above reason.
IIRC Herbert had the same doubts some time ago, I wonder what
made him change his mind.

> What I initially wanted was to publish something like "Device wlan0 is
> managed by netlink pid 12345" (or 0 if the kernel is doing it) and then
> configuration would be "send to <number the kernel told you>". However,
> that got me into problems when trying to determine "is the process
> owning netlink pid 12345 still alive" at which point Herbert suggested
> the use of multicast groups (and doing the exclusion "only one manager
> per netdev" in userspace instead of the kernel).


There is a notifier for userspace unicast socket releases, would adding
another one for multicast groups help?
