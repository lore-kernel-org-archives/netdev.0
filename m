From: "Luis Carlos Cobo" <luisca@cozybit.com>
Subject: Re: Proposed interface for per-packet mesh-ttl
Date: Thu, 16 Aug 2007 12:21:14 -0700
Message-ID: <8e8340660708161221t1c0bee01g9d0cb1835f7026f0@mail.gmail.com>
References: <445f43ac0707031149o2b50fc0en48aef4130b4b60ec@mail.gmail.com>
	 <445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
	 <20070727195616.GA31510@infradead.org>
	 <1185574942.17934.9.camel@xo-13-A4-25.localdomain>
	 <20070728073145.57155e03@oldman>
	 <445f43ac0707301337l2f7d62ebx6955a12cd89c6bd3@mail.gmail.com>
	 <20070730215316.5c236e18@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Javier Cardona" <javier@cozybit.com>,
	"Dan Williams" <dcbw@redhat.com>,
	"Christoph Hellwig" <hch@infradead.org>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:20054 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613AbXHPTVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 15:21:17 -0400
Received: by ik-out-1112.google.com with SMTP id b32so77986ika
        for <netdev@vger.kernel.org>; Thu, 16 Aug 2007 12:21:15 -0700 (PDT)
In-Reply-To: <20070730215316.5c236e18@oldman>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/30/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> it would need an IP ttl to mesh mapping. The fundamental thing is to try
> and avoid topology specific options bleeding all the way up the socket layer,
> especially since the network layer is involved and may need to multipath.

I think the cleanest way would be to add a ll_ttl (ll for link layer)
field to struct sock and a SO_LL_TTL socket option that sets both the
field and a flag in sk->flags. This way it is useful for any driver
that can do mesh or any other protocol that involves a ttl at link
layer (not that I'm aware of any).

However I guess you are not supposed to add new socket options nor
modify struct socket too often so I'd appreciate feedback on whether
this would be considered a good approach.

-- 
Luis Carlos Cobo Rus       GnuPG ID: 44019B60
cozybit Inc.
