From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] ipv4: add link_filter sysctl
Date: Wed, 18 Mar 2009 19:42:39 -0700
Message-ID: <20090318194239.1adc47d2@nehalam>
References: <20090313161253.0f02da26@nehalam>
	<20090318.182115.43965264.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57770 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753889AbZCSCms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 22:42:48 -0400
In-Reply-To: <20090318.182115.43965264.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Mar 2009 18:21:15 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 13 Mar 2009 16:12:53 -0700
> 
> > Add a new parameter that controls how kernel responds to packets
> > when interface is down. This is done to solve the problem of:
> > 
> > Assume topology of:
> >       A <----------->       Router             X--- down link
> >  10.1.1.2/24       10.1.1.1/24    10.2.1.1/24 
> >                      eth0          eth1
> > 
> > If A pings 10.2.1.1 then with normal Linux semantics Router would
> > respond even if eth1 link on 10.2.1.1 was down. This causes some network
> > management tools (that work with other router OS's) to falsely
> > report that link is okay.
> > 
> > The problem is that a Linux router does not respond the way
> > other systems do. This is the router equivalent of "Strong ES"
> > model, it is not the same as "Strong ES" as defined in Host
> > Requirements.
> > 
> > The new parameter adds an additional check on slow input packet
> > path, and causes route cache flush if enabled and carrier is
> > lost.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> There is nothing "router" about this situation.
> 
> When 10.2.1.1 is being pinged, it is in the role of an end-system in
> that transaction.
> 
> The "router" is reachable by "A", and as a consequence so is that IP
> address 10.2.1.1, and therefore the ping should succeed.

Unfortunately, network management tools expect routers to behave this
way: WWCD
