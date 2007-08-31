From: David Miller <davem@davemloft.net>
Subject: Re: pktgen terminating condition
Date: Thu, 30 Aug 2007 22:19:09 -0700 (PDT)
Message-ID: <20070830.221909.28790079.davem@davemloft.net>
References: <1188395183.4274.19.camel@localhost>
	<18133.40847.166882.838333@robur.slu.se>
	<1188475721.22423.35.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, mandeep.baines@gmail.com,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	grundler@google.com, robert.olsson@its.uu.se, venza@brownhat.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59462
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758452AbXHaFTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 01:19:10 -0400
In-Reply-To: <1188475721.22423.35.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 30 Aug 2007 08:08:40 -0400

> I was confusing it with another issue where pktgen could send a lot of
> packets without waiting for them to be freed; there are some drivers
> (10G) which may hold onto 8K skbs. A gazillion ooms start spewing ;-> My
> thinking in resolving that was to do something like waht sockets do and
> charge pktgen so it doesnt have too many outstanding packets in flight.

You could implement this quite simply using skb->destructor.

It will add some atomics, so on weaker pktgen source systems
it might decrease the generators rate.
