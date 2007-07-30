From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Proposed interface for per-packet mesh-ttl
Date: Mon, 30 Jul 2007 21:53:16 +0100
Message-ID: <20070730215316.5c236e18@oldman>
References: <445f43ac0707031149o2b50fc0en48aef4130b4b60ec@mail.gmail.com>
	<445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
	<20070727195616.GA31510@infradead.org>
	<1185574942.17934.9.camel@xo-13-A4-25.localdomain>
	<20070728073145.57155e03@oldman>
	<445f43ac0707301337l2f7d62ebx6955a12cd89c6bd3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Dan Williams" <dcbw@redhat.com>,
	"Christoph Hellwig" <hch@infradead.org>, netdev@vger.kernel.org
To: "Javier Cardona" <javier@cozybit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54342 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933154AbXG3Ux0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 16:53:26 -0400
In-Reply-To: <445f43ac0707301337l2f7d62ebx6955a12cd89c6bd3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Jul 2007 13:37:20 -0700
"Javier Cardona" <javier@cozybit.com> wrote:

> Hi Stephen,
> 
> On 7/27/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > In this case perhaps you can have a table that maps skb->priority to
> > mesh ttl? priorty can already by handled by existing setsockopt calls,
> > and modified by netfilter and QoS managements.
> 
> Thanks for the feedback.  IMHO overloading the [SOL_SOCKET]
> SO_PRIORITY  sockoption for something as different as changing the
> mesh-ttl is quite a stretch.   But I admit that it meets the driver
> requirements of "never add sockopt" and "not [ab]use netfilter hooks".
>  If that's acceptable to all, I'll modify the patch in that direction.
> 
> Cheers,
> 
> Javier

Take it as idea not a proscription.  You can use TC rules to rewrite
the priority.  It is kind of like how priority is being mapped to TOS already
in softmac. Alternatively, the TTL can be set with sockopt, but it is a IP so
it would need an IP ttl to mesh mapping. The fundamental thing is to try
and avoid topology specific options bleeding all the way up the socket layer,
especially since the network layer is involved and may need to multipath.
