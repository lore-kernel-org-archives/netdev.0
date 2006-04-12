From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] atm: clip causes unregister hang
Date: Wed, 12 Apr 2006 13:15:27 -0700
Message-ID: <20060412131527.71f42d58@localhost.localdomain>
References: <20060412105545.3b089dd8@localhost.localdomain>
	<E1FTjlM-00050V-00@gondolin.me.apana.org.au>
	<20060412124533.14e0c4ff@localhost.localdomain>
	<20060412200015.GA19878@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45227 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932179AbWDLUP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 16:15:58 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060412200015.GA19878@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 06:00:15 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi Stephen:
> 
> On Wed, Apr 12, 2006 at 12:45:33PM -0700, Stephen Hemminger wrote:
> >
> >  	/* ignore non-CLIP devices */
> > -	if (((struct net_device *) dev)->type != ARPHRD_ATM ||
> > -	    ((struct net_device *) dev)->hard_start_xmit != clip_start_xmit)
> > +	if (dev->type != ARPHRD_ATM || dev->hard_start_xmit != clip_start_xmit)
> >  		return NOTIFY_DONE;
> 
> I think we need to check whether atm_init_atmarp has been done before
> passing this point.  We also need to make sure that it doesn't get pulled
> out from under us while we're doing this.
> 
> Cheers,

If atm_init_atmarp has not been done, then to_atamarpd is a nop because
atmarpd == NULL.
