From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] dont create cached routes from ARP requests
Date: Wed, 22 Sep 2010 20:34:42 -0700 (PDT)
Message-ID: <20100922.203442.233700254.davem@davemloft.net>
References: <20100922162209.GA10281@babylon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: uweber@astaro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49607
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751662Ab0IWDeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 23:34:22 -0400
In-Reply-To: <20100922162209.GA10281@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <uweber@astaro.com>
Date: Wed, 22 Sep 2010 18:22:09 +0200

> Do we really have to cache routes based on ARP requests?
> Are there any other reasons than expecting new connections?
> 
> Attached is a patch to skip caching for ARP requests
> not related to local IP addresses or ARP proxy.
> 
> Background: At home I have two Internet connections, DSL and Cable.
> DSL is the primary uplink while Cable is the secondary.
> My Cable ISP is flooding me with ARP request from 10.0.0.0/8,
> which creates routes via the primary uplink.
> There are thousands of cached routes and after some time
> I get "Neighbour table overflow" messages.

If you get neighbour table overflows, something is holding a reference
to the routing cache entry and/or the neighbour entries those routing
cache entries are attached to.

If these really are transient entries, they should be trivially
garbage collected and not cause any problems at all.
