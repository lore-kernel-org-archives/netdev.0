From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Proposed interface for per-packet mesh-ttl
Date: Thu, 16 Aug 2007 17:19:13 -0400
Message-ID: <20070816171913.2ad87e47@oldman>
References: <445f43ac0707031149o2b50fc0en48aef4130b4b60ec@mail.gmail.com>
	<445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
	<20070727195616.GA31510@infradead.org>
	<1185574942.17934.9.camel@xo-13-A4-25.localdomain>
	<20070728073145.57155e03@oldman>
	<445f43ac0707301337l2f7d62ebx6955a12cd89c6bd3@mail.gmail.com>
	<20070730215316.5c236e18@oldman>
	<8e8340660708161221t1c0bee01g9d0cb1835f7026f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Javier Cardona" <javier@cozybit.com>,
	"Dan Williams" <dcbw@redhat.com>,
	"Christoph Hellwig" <hch@infradead.org>, netdev@vger.kernel.org
To: "Luis Carlos Cobo" <luisca@cozybit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41671 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757963AbXHPVSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 17:18:52 -0400
In-Reply-To: <8e8340660708161221t1c0bee01g9d0cb1835f7026f0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Aug 2007 12:21:14 -0700
"Luis Carlos Cobo" <luisca@cozybit.com> wrote:

> On 7/30/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > it would need an IP ttl to mesh mapping. The fundamental thing is to try
> > and avoid topology specific options bleeding all the way up the socket layer,
> > especially since the network layer is involved and may need to multipath.
> 
> I think the cleanest way would be to add a ll_ttl (ll for link layer)
> field to struct sock and a SO_LL_TTL socket option that sets both the
> field and a flag in sk->flags. This way it is useful for any driver
> that can do mesh or any other protocol that involves a ttl at link
> layer (not that I'm aware of any).
> 
> However I guess you are not supposed to add new socket options nor
> modify struct socket too often so I'd appreciate feedback on whether
> this would be considered a good approach.
> 
> -- 
> Luis Carlos Cobo Rus       GnuPG ID: 44019B60
> cozybit Inc.

The problem with socket options is how does the application know
the correct policy? Pushing configuration to application is just deferring
the problem, not solving it.  You want some policy to be done by the
infrastructure; that means kernel, libraries, daemons, etc. Doing it in
the application is often inflexible and unusable.
