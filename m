From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Tue, 02 Sep 2014 11:36:13 +0200
Message-ID: <1409650573.1808.11.camel@jlt4.sipsolutions.net>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
	 (sfid-20140821_192515_304437_37E734D5) <1408642331.4388.2.camel@jlt4.sipsolutions.net>
	 <1409125114.11976.14.camel@localhost>
	 <1409130313.2505.3.camel@jlt4.sipsolutions.net>
	 <1409133238.26515.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54494 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722AbaIBJgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 05:36:16 -0400
In-Reply-To: <1409133238.26515.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-08-27 at 11:53 +0200, Hannes Frederic Sowa wrote:

> > I don't know if that's really useful? OTOH, there surely must have been
> > a reason for this to be in the IPv4 RFC, so maybe for that same reason
> > it should also be in the IPv6 RFC?
> 
> Either it is an oversight, but RFC6085 3) tries to at least clarify the
> multicast destination with LL unicast address. So there must have been
> people trying to enfore a relationship between LL address and IPv6 one.

That seems to allow a multicast IPv6 frame in a unicast LL address,
which is a different situation but still ...

> I think it would be OK to drop it by default in case we don't break any
> other assumptions in the stack (e.g. CLUSTERIP).

Fair enough.

> > The question now is, in the absence of such a latter required check (and
> > indeed, in the case of CLUSTERIP), how we implement such a check.
> > Perhaps a sysctl is needed after all?
> 
> Yeah, unfortunate situation.
> 
> One could add those IP addresses as broadcast addresses (/32) to the
> routing table, so the brd_input jump would be taken.
> 
> But this would still break users of CLUSTERIP until they install those
> routes. :(

I'm not even sure I understand this part :)

Any suggestions?

As long as IPv6 doesn't mandate it in the RFCs I'm not really sure we
should just drop it, even if we think it won't cause any problems?

CLUSTERIP seems like a special configuration, but I'm not sure it can be
detected and automatically allowed?

johannes
