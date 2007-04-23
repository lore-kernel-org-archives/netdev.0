From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 13:37:30 -0700 (PDT)
Message-ID: <20070423.133730.115642229.davem@davemloft.net>
References: <20070423130734.d3d90b20.akpm@linux-foundation.org>
	<20070423.131810.78710074.davem@davemloft.net>
	<20070423132719.b7cf1c9e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35640
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754174AbXDWUhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 16:37:23 -0400
In-Reply-To: <20070423132719.b7cf1c9e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 23 Apr 2007 13:27:19 -0700

> On Mon, 23 Apr 2007 13:18:10 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Mon, 23 Apr 2007 13:07:34 -0700
> > 
> > > The interesting bit is:
> >  ...
> > > I think I saw the same problem maybe 1.5 weeks ago on this machine, but I
> > > didn't have time to investigate further.  So it's not some recent thing.
> > 
> > My initial reaction is that DNS responses are being lost or dropped
> > for some reason.
> 
> Plausible.   I'll try booting it with the ethernet unplugged.

That won't test the same scenerio.

If the network cable is unplugged, ARP responses won't arrive and
therefore sendmsg() calls will return with a host unreachable error.

The situation you need to recreate is specifically UDP packets getting
dropped.

The reason I wanted the tcpdump trace is so that we can see whether
the problem is UDP packets going out or going in which are being
mangled/dropped.

You don't need a hub to get a dump.  Instead you can run a caching
named on some other system, configure your FC6 box to use that system
for DNS via /etc/resolv.conf, then run tcpdump on the caching named
machine.
