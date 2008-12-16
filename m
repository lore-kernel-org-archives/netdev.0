From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
	negotiation
Date: Tue, 16 Dec 2008 20:25:59 -0200
Message-ID: <20081216222559.GR14518@ghostprotocols.net>
References: <20081216052954.GA6199@gerrit.erg.abdn.ac.uk> <20081216.014045.217150811.davem@davemloft.net> <20081216111908.GI14518@ghostprotocols.net> <20081216.133200.229085084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, gerrit@erg.abdn.ac.uk, mirqus@gmail.com,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51453 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753396AbYLPW0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 17:26:11 -0500
Content-Disposition: inline
In-Reply-To: <20081216.133200.229085084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Dec 16, 2008 at 01:32:00PM -0800, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Tue, 16 Dec 2008 09:19:08 -0200
> 
> > I guess that looking at tcp_set_congestion_control() could be a good
> > start. 8-)
> 
> Certainly.
> 
> But it seems to me we are dealing with a different situation here
> in DCCP.
> 
> On the TCP side we have:
> 
> 1) A default congestion control module, already loaded and
>    which has been selected by the admin via a sysctl setting.

Which we should have in DCCP too, its even in the RFC that CCID2 should
be always available, making a good choice for a default one.
 
> 2) A socket option facility to select a non-default congestion
>    control algorithm to use.

This is the same for DCCP, i.e. the app can tell the ones it wants via
setsockopt, and if the default is all they want, no need to ask for
something to be loaded, i.e. ccid2 (or the one that we think should be
the default, like reno -> BIC -> CUBIC) should be always available.
 
> These are both outside of the fast path.
> 
> Whereas the DCCP case is right in the connection creation fast path
> and unconditionally executes, because it is trying to figure out what
> CCID algorithms it can advertise.

Well, there must be some way to locklessly advertise what was previously
loaded (and thus can't ever be unloaded).

- Arnaldo
