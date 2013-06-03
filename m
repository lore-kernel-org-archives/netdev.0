From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCHv2 net-next] netlink: allow large data transfers from
 user-space
Date: Mon, 3 Jun 2013 19:41:38 +0200
Message-ID: <20130603174138.GA28338@localhost>
References: <1370277599-27072-1-git-send-email-pablo@netfilter.org>
 <1370279559.24311.160.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57197 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663Ab3FCRln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 13:41:43 -0400
Content-Disposition: inline
In-Reply-To: <1370279559.24311.160.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric!

On Mon, Jun 03, 2013 at 10:12:39AM -0700, Eric Dumazet wrote:
> On Mon, 2013-06-03 at 18:39 +0200, Pablo Neira Ayuso wrote:
> 
> > +	if (is_vmalloc_addr(skb->head)) {
> > +		vfree(skb->head);
> > +		skb->data = NULL;
> > +	}
> >  
> 
> You probably meant :
> 
> 	skb->head = NULL;
> 
> Now, cross our fingers we do not skb_orphan() these skb too early :)

skb_release_all checks for skb->data != NULL to release skb->head as
it would have been allocated via kmalloc. This didn't look very
intuitive to me when I hit a panic while testing my patch either.

So unless I'm missing anything, that skb->data is OK with the existing
code we have.

Regards.
