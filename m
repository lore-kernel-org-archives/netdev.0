From: Ulrich Weber <uweber@astaro.com>
Subject: Re: [RFC PATCH] dont create cached routes from ARP requests
Date: Thu, 23 Sep 2010 16:47:08 +0200
Message-ID: <20100923144708.GA8037@babylon>
References: <20100922162209.GA10281@babylon>
 <20100922.203442.233700254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-77.dex002.intermedia.net ([64.78.20.107]:26377 "EHLO
	DHOST002-77.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754576Ab0IWOrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 10:47:14 -0400
Content-Disposition: inline
In-Reply-To: <20100922.203442.233700254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 22, 2010 at 08:34:42PM -0700, David Miller wrote:
> From: Ulrich Weber <uweber@astaro.com>
> Date: Wed, 22 Sep 2010 18:22:09 +0200
> 
> > Background: At home I have two Internet connections, DSL and Cable.
> > DSL is the primary uplink while Cable is the secondary.
> > My Cable ISP is flooding me with ARP request from 10.0.0.0/8,
> > which creates routes via the primary uplink.
> > There are thousands of cached routes and after some time
> > I get "Neighbour table overflow" messages.
> 
> If you get neighbour table overflows, something is holding a reference
> to the routing cache entry and/or the neighbour entries those routing
> cache entries are attached to.
> 
> If these really are transient entries, they should be trivially
> garbage collected and not cause any problems at all.
rt_garbage_collect is not called within rt_intern_hash,
because the call is done within softirq context.

Forcing the call of rt_garbage_collect didn't help either,
there are no routes freed afterwards...

Cheers
 Ulrich
