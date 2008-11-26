From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 03/53] netns xfrm: add struct xfrm_state::xs_net
Date: Wed, 26 Nov 2008 07:25:02 +0300
Message-ID: <20081126042502.GA2549@x200.localdomain>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com> <1227634045-27534-2-git-send-email-adobriyan@gmail.com> <1227634045-27534-3-git-send-email-adobriyan@gmail.com> <20081125.171536.03980167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:32356 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbYKZEVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 23:21:08 -0500
Received: by ey-out-2122.google.com with SMTP id 6so126169eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 20:21:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081125.171536.03980167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2008 at 05:15:36PM -0800, David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Tue, 25 Nov 2008 20:26:35 +0300
> 
> > To avoid unnecessary complications with passing netns around.
> > 
> > * set once, very early after allocating
> > * once set, never changes
> > 
> > For a while create every xfrm_state in init_net.
> > 
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> Applied.
> 
> > @@ -223,6 +226,11 @@ struct xfrm_state
> >  	void			*data;
> >  };
> >  
> > +static inline struct net *xs_net(struct xfrm_state *x)
> > +{
> > +	return read_pnet(&x->xs_net);
> > +}
> > +
> >  /* xflags - make enum if more show up */
> 
> Look mom, no ifdefs!  Amazing!

There're gone and won't return, honey.

In fact, I don't like pnet only a little now and thinking about:

	net = read_net(foo->foo_net);
	write_net(foo->foo_net, net);
