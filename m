From: Patrick McHardy <kaber@trash.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Wed, 04 Jul 2007 17:00:08 +0200
Message-ID: <468BB5F8.3080908@trash.net>
References: <1183492286.4021.21.camel@johannes.berg>	 <468BAADC.4030203@trash.net> <1183558702.3812.33.camel@johannes.berg>	 <468BAF10.6080208@trash.net> <1183559883.3812.42.camel@johannes.berg>	 <468BB327.5050709@trash.net> <1183561006.3812.47.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39403 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755469AbXGDPBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 11:01:15 -0400
In-Reply-To: <1183561006.3812.47.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Wed, 2007-07-04 at 16:48 +0200, Patrick McHardy wrote:
> 
> 
>>Yes, although in both cases you have no guarantee how long its
>>going to take, someone else could be flooding the receive queue.
>>For userspace this is more likely to be a real problem though
>>since the kernel will keep processing the queue as long as packets
>>are in it, while userspace could be scheduled away.
> 
> 
> Right, but in the case of wireless you'll have different problems if
> that happens, namely your wireless card won't be reassociating etc. I
> don't think it'll be a problem in practice.


Not by itself probably but a user could DoS your wireless connectivity
this way.

>>I'm not so sure myself whether netlink is really a good idea for
>>userspace<->userspace communication because of the above reason.
>>IIRC Herbert had the same doubts some time ago, I wonder what
>>made him change his mind.
> 
> 
> Hm. The reason I wanted it initially is that this way we can guarantee
> that userspace programs work in either case and also that we have better
> control over the various APIs.
> 
> 
>>There is a notifier for userspace unicast socket releases, would adding
>>another one for multicast groups help?
> 
> 
> Huh I think that notifier is enough in fact. It'll be called if a
> userspace process closes a socket or such, right? Might get a lot of
> events for generic netlink but that should be acceptable since it'd only
> need to check .pid to start with.


I'm not sure, it would probably also have to be called when userspace
unsubscribes from a group, no?
