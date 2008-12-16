From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
 negotiation
Date: Tue, 16 Dec 2008 15:11:51 -0800 (PST)
Message-ID: <20081216.151151.220977047.davem@davemloft.net>
References: <20081216111908.GI14518@ghostprotocols.net>
	<20081216.133200.229085084.davem@davemloft.net>
	<20081216222559.GR14518@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, mirqus@gmail.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49145
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752880AbYLPXLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:11:50 -0500
In-Reply-To: <20081216222559.GR14518@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 16 Dec 2008 20:25:59 -0200

> Em Tue, Dec 16, 2008 at 01:32:00PM -0800, David Miller escreveu:
> > From: Arnaldo Carvalho de Melo <acme@redhat.com>
> > Date: Tue, 16 Dec 2008 09:19:08 -0200
> > 
> > Whereas the DCCP case is right in the connection creation fast path
> > and unconditionally executes, because it is trying to figure out what
> > CCID algorithms it can advertise.
> 
> Well, there must be some way to locklessly advertise what was previously
> loaded (and thus can't ever be unloaded).

This gets us back to my original objection.

Can these things be unloaded?  If not, and they get unconditionally
all loaded up on the first DCCP connection, why make them seperate
modules at all?

If they can get unloaded, then you need synchronization.

I would recommend that everything gets built into dccp.ko
and thus the table is fixed and never changes and thus no
locking nor any of this funny mod loading is needed at all.
