From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf] netfilter: conntrack: fix race in
 __nf_conntrack_confirm against get_next_corpse
Date: Fri, 14 Nov 2014 17:40:54 +0100
Message-ID: <20141114164054.GA4222@salvia>
References: <012601cff7d1$7ce2d620$76a88260$@gmail.com>
 <20141106133648.2534.1403.stgit@dragon>
 <20141110165439.GA7788@salvia>
 <20141112083500.5404e5f4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: programme110@gmail.com, netfilter-devel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Joerg Marx <joerg.marx@secunet.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37636 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965742AbaKNQjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2014 11:39:00 -0500
Content-Disposition: inline
In-Reply-To: <20141112083500.5404e5f4@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2014 at 08:35:00AM +0100, Jesper Dangaard Brouer wrote:
> > > -	/* We have to check the DYING flag inside the lock to prevent
> > > +
> > > +	/* We have to check the DYING flag after unlink to prevent
> > >  	   a race against nf_ct_get_next_corpse() possibly called from
> > >  	   user context, else we insert an already 'dead' hash, blocking
> > >  	   further use of that particular connection -JM */
> > 
> > While at this, I think it would be good to fix comment style to:
> > 
> >         /* We have ...
> >          * ...
> >          */
> > 
> > I can fix this here, no need to resend, just let me know.
> 
> Okay, I was just trying to keep the changes as minimal as possible, if
> this should go into a stable-kernel.  Your choice.

I'm going to take this patch including the comment style fix, I would
like to avoid specific patches to fix coding style issues, and the
first line of this comment is updated. I think the patch will be still
small to fulfill -stable rules.

I'll send a follow a patch to change the return verdict to NF_DROP to
not mix up different things.

Thanks!
