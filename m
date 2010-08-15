From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: GTSM and TCP accept problem
Date: Sun, 15 Aug 2010 12:38:40 -0400
Message-ID: <20100815123840.487a5afc@s6510>
References: <20100814214634.24a87715@s6510>
	<20100814.221258.35029372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35999 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932813Ab0HOQiq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Aug 2010 12:38:46 -0400
In-Reply-To: <20100814.221258.35029372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Aug 2010 22:12:58 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Sat, 14 Aug 2010 21:46:34 -0400
> 
> > The implementation of Generalized TTL Security has a problem
> > on the TCP accept side. Since there can be different number of
> > hops for each peer, the listener ends up doing
> > 
> >    socket
> >    bind
> >    set TTL to 255
> >    listen
> >    while (nfd = accept(peer)) {
> >      info = lookup(peer)
> >      set MINTTL to 255 - info->ttl_hops
> 
> Surely when creating the initial listening socket we should use the
> minimum TTL over the set of peers right?
> 
> That surely takes most of the fun out of this problem for the
> attacker.

That only works if all peers are external and using ttl-security.
If any peer is not using ttl-security, then that peer will be
sending with low TTL and the SYN would get dropped.

The real problem goes back to the GTSM RFC assumptions that TTL
security will be done by firewall, not TCP itself.
