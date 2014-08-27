From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Wed, 27 Aug 2014 11:53:58 +0200
Message-ID: <1409133238.26515.13.camel@localhost>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
	 (sfid-20140821_192515_304437_37E734D5) <1408642331.4388.2.camel@jlt4.sipsolutions.net>
	 <1409125114.11976.14.camel@localhost>
	 <1409130313.2505.3.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:51031 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933200AbaH0JyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 05:54:02 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id A455B208BC
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 05:54:00 -0400 (EDT)
In-Reply-To: <1409130313.2505.3.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-08-27 at 11:05 +0200, Johannes Berg wrote:
> On Wed, 2014-08-27 at 09:38 +0200, Hannes Frederic Sowa wrote:
> 
> > > And if it's *not* in the IPv6 RFCs, how should we implement this?
> > 
> > I haven't found anything, too. Should I bring this up with IETF?
> 
> I don't know if that's really useful? OTOH, there surely must have been
> a reason for this to be in the IPv4 RFC, so maybe for that same reason
> it should also be in the IPv6 RFC?

Either it is an oversight, but RFC6085 3) tries to at least clarify the
multicast destination with LL unicast address. So there must have been
people trying to enfore a relationship between LL address and IPv6 one.

I think it would be OK to drop it by default in case we don't break any
other assumptions in the stack (e.g. CLUSTERIP).

> However, in our particular case, it's really meant only to close the
> so-called "hole-196" vulnerability where rogue clients in your network
> can abuse the GTK to do some attacks. Those attacks are also always
> possible on non-managed ethernet segments, but those can be segregated
> more easily by client than shared medium wireless.
> 
> This is only one building block for addressing the vulnerability. The
> idea here was that in the wireless stack we already check
> 
> frame encrypted with GTK => must have multicast destination address
> 
> and in the IPv4 stack we can check
> 
> frame has multicast destination address => must have multicast/broadcast
> IP addr
> 
> This would address this point.

Yes, I was in the room when we discussed this. ;) To me at that time it
seemed like an easy and good solution.

> The question now is, in the absence of such a latter required check (and
> indeed, in the case of CLUSTERIP), how we implement such a check.
> Perhaps a sysctl is needed after all?

Yeah, unfortunate situation.

One could add those IP addresses as broadcast addresses (/32) to the
routing table, so the brd_input jump would be taken.

But this would still break users of CLUSTERIP until they install those
routes. :(

Bye,
Hannes
