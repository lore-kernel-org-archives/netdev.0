From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC] Suspicious bug in module refcounting
Date: Wed, 11 Feb 2009 00:06:31 +1030
Message-ID: <200902110006.33132.rusty@rustcorp.com.au>
References: <20090203134721.GA11069@pingi.kke.suse.de> <200902101345.08580.rusty@rustcorp.com.au> <20090210103136.GB7096@dhcp35.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Karsten Keil <kkeil@suse.de>, linux-kernel@vger.kernel.org,
	richard kennedy <richard@rsk.demon.co.uk>,
	Dan Williams <dan.j.williams@intel.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	dwmw2@infradead.org, Scott Wood <scottwood@freescale.com>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: Michal Hocko <mhocko@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41845 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751920AbZBJNgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2009 08:36:38 -0500
In-Reply-To: <20090210103136.GB7096@dhcp35.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 10 February 2009 21:01:37 Michal Hocko wrote:
> On Tue 10-02-09 13:45:07, Rusty Russell wrote:
> > On Tuesday 10 February 2009 01:48:31 Michal Hocko wrote:
> > > Based on this change, would it make sense to update sys_accept to change
> > > __module_get to try_module_get like in the following patch?
> > 
> > I don't think so:
> > 
> > >  	/*
> > > -	 * We don't need try_module_get here, as the listening socket (sock)
> > > -	 * has the protocol module (sock->ops->owner) held.
> > > +	 * Socket's owner cannot be in unloading path because there
> > > +	 * must be at least one listening reference
> > >  	 */
> > > -	__module_get(newsock->ops->owner);
> > > +	if (unlikely(!try_module_get(newsock->ops->owner)))
> > > +		BUG();
> > 
> > rmmod --wait can make try_module_get fail even if the reference count isn't
> > zero.  
> 
> OK, I though that rmmod --wait waits for refcount==0 and then changes
> the state.

No, it has to stop all future use, otherwise it's useless under load.

Cheers,
Rusty.
