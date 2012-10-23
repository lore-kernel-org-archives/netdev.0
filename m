From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next] sockopt: Introduce the SO_BINDTOIFINDEX
Date: Tue, 23 Oct 2012 17:43:45 -0400
Message-ID: <50870F91.8000801@hp.com>
References: <5086A7FD.3020503@parallels.com> <20121023.133602.1844873902881466397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:24302 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334Ab2JWVnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 17:43:47 -0400
In-Reply-To: <20121023.133602.1844873902881466397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2012 01:36 PM, David Miller wrote:
> 
> This is really a huge ball of confusion.
> 
> The user asks for a device to bind to, and they want the device which
> had a particular name at the time of the call.
> 
> If you allow setting this via ifindex, the issues and races are the
> same whether the name-->ifindex translation is done before the
> sockopt() call or during it.

Yes, there are race conditions in the socket APIs, even IP addresses can go away
right before a bind() call.

> Furthermore both the name and the ifindex can change (that latter
> via module unload/load).
> 
> If you want me to consider these changes seriously, talk less about
> obtuse issues like symmetry and more about what problems it actually
> solves.  As far as I can tell, all the same real issues still exist
> even if we had this new interface.

Noone's complained about not having this getsockopt() for over 7+ years, so in
that sense I'm not sure what problem it solved adding it.

> In fact, I wouldn't mind if a getsockopt() on SO_BINDTODEVICE returned
> BOTH the name and the ifindex in a special structure.  Then you could
> actually construct a more foolproof mechanism on the user side to try
> various ways to get the same device bound to during restart.

There is no fool-proof way to do any of this since we can agree device names and
indexes can change.  But people aren't typically running daemons listening on
interfaces that are constantly changing like taps or tunnels, instead it's on
eth1 so they can run a private DHCP server.

> Symmetry is over-rated.

If any of the other SO_* options didn't set and get using the same structure I'd
agree with you, but I can't find any that do.

-Brian
