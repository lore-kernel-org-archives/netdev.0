From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Bug ? IF_RUNNING/routing table updates
Date: Wed, 11 Oct 2006 13:01:26 +0200
Message-ID: <20061011110126.GB1671@ff.dom.local>
References: <018201c6eb91$816764e0$8100a8c0@stealth00025>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:24750 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1751192AbWJKK4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 06:56:38 -0400
To: Shaun Kemp <shaun.kemp@stealthnet.net>
Content-Disposition: inline
In-Reply-To: <018201c6eb91$816764e0$8100a8c0@stealth00025>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09-10-2006 12:55, Shaun Kemp wrote:
...
> An interface (+ connected IP network) which loses its IF_RUNNING flag (ie
> unusable for routing) persists in the routing table as a kernel route.
> Thus rather than responding to a dynamically announced route to this
> connected network (the connected being unreachable due to the interface
> being down, but the dynamic offering an alternate path), the box insists on
> trying to route it out of the broken interface via this ?kernel? sourced
> route.
...
> The path for 192.168.0.192 is learned via 192.168.0.130 (current ospf dr -
> irrelevant), but it'll never use it presumably (from Cisco experience)
> because of the kernel sourced directly connected route still sitting in
> there. Furthermore, if I then IFDOWN eth1, everything is fine but I don't
> want to do this manually everytime there's an interface problem because
> that's why we run ospf ! =:D
> 
> Not sure whether this is a "driver tells the kernel" or a "kernel checks the
> driver at {n} intervals" issue - I would suggest the former would be more
> correct, but it is a problem regardless.
> 
> Maybe it's just these Intel drivers ? :/

IMHO it should be done by the same part which changed the
flag - for this purpose routing frontend is listening for
notify events.
 
Jarek P.
