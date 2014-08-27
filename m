From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Wed, 27 Aug 2014 11:05:13 +0200
Message-ID: <1409130313.2505.3.camel@jlt4.sipsolutions.net>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
	 (sfid-20140821_192515_304437_37E734D5) <1408642331.4388.2.camel@jlt4.sipsolutions.net>
	 <1409125114.11976.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:44572 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310AbaH0JFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 05:05:18 -0400
In-Reply-To: <1409125114.11976.14.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-08-27 at 09:38 +0200, Hannes Frederic Sowa wrote:

> > And if it's *not* in the IPv6 RFCs, how should we implement this?
> 
> I haven't found anything, too. Should I bring this up with IETF?

I don't know if that's really useful? OTOH, there surely must have been
a reason for this to be in the IPv4 RFC, so maybe for that same reason
it should also be in the IPv6 RFC?

However, in our particular case, it's really meant only to close the
so-called "hole-196" vulnerability where rogue clients in your network
can abuse the GTK to do some attacks. Those attacks are also always
possible on non-managed ethernet segments, but those can be segregated
more easily by client than shared medium wireless.

This is only one building block for addressing the vulnerability. The
idea here was that in the wireless stack we already check

frame encrypted with GTK => must have multicast destination address

and in the IPv4 stack we can check

frame has multicast destination address => must have multicast/broadcast
IP addr

This would address this point.

The question now is, in the absence of such a latter required check (and
indeed, in the case of CLUSTERIP), how we implement such a check.
Perhaps a sysctl is needed after all?

johannes
