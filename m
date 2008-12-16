From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
	negotiation
Date: Tue, 16 Dec 2008 09:19:08 -0200
Message-ID: <20081216111908.GI14518@ghostprotocols.net>
References: <e2d7436a0812140650r41b601dfgc3bbf41f01c2bb5d@mail.gmail.com> <36660.148.187.160.35.1229358346.squirrel@148.187.160.35> <20081216052954.GA6199@gerrit.erg.abdn.ac.uk> <20081216.014045.217150811.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerrit@erg.abdn.ac.uk, mirqus@gmail.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58410 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091AbYLPLTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 06:19:17 -0500
Content-Disposition: inline
In-Reply-To: <20081216.014045.217150811.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Dec 16, 2008 at 01:40:45AM -0800, David Miller escreveu:
> From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Date: Tue, 16 Dec 2008 06:29:54 +0100
> 
> > | Hence I think we have a chance by going completely lockless here, by
> > | loading all configured CCIDs at runtime. In this manner the per-connection
> > | check "are all advertised CCIDs are loaded?" falls under the table, we
> > | do not need to worry about concurrent access, and loading DCCP implies that
> > | all needed CCIDs are there.
> > Unfortunately this won't work since the CCIDs depend on dccp.ko being
> > fully loaded, so requiring that CCID module are loaded during the
> > loading process of dccp.ko creates a cyclic dependency.
> 
> I don't like this stuff at all.
> 
> Every new connection you're going to loop over the CCID
> table and grab that CCID read lock N times.
> 
> The first time it will do something meaningful, and then
> %99.999999999999 of subsequent calls will do nothing.
> 
> What kind of overhead is deserved by that access pattern?
> 
> And, if the first thing the first connection is going to do
> is load all the modules, there is ZERO reason to make them
> modular.  It's just useless seperation and it adds all of
> this rediculious synchronization.
> 
> If it's modular "for the sake of development" I'm sure you
> can simply reload the dccp.ko module when you make some
> CCID algorithm change.
> 
> I'm tossing this patch set until we get something better
> in this area.

I guess that looking at tcp_set_congestion_control() could be a good
start. 8-)

- Arnaldo
