From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] Suspicious bug in module refcounting
Date: Tue, 10 Feb 2009 11:31:37 +0100
Message-ID: <20090210103136.GB7096@dhcp35.suse.cz>
References: <20090203134721.GA11069@pingi.kke.suse.de> <200902041418.09630.rusty@rustcorp.com.au> <20090209151830.GC6018@dhcp35.suse.cz> <200902101345.08580.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Karsten Keil <kkeil@suse.de>, linux-kernel@vger.kernel.org,
	richard kennedy <richard@rsk.demon.co.uk>,
	Dan Williams <dan.j.williams@intel.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	dwmw2@infradead.org, Scott Wood <scottwood@freescale.com>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50336 "EHLO dhcp35"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752722AbZBJKbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2009 05:31:38 -0500
Content-Disposition: inline
In-Reply-To: <200902101345.08580.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue 10-02-09 13:45:07, Rusty Russell wrote:
> On Tuesday 10 February 2009 01:48:31 Michal Hocko wrote:
> > Based on this change, would it make sense to update sys_accept to change
> > __module_get to try_module_get like in the following patch?
> 
> I don't think so:
> 
> >  	/*
> > -	 * We don't need try_module_get here, as the listening socket (sock)
> > -	 * has the protocol module (sock->ops->owner) held.
> > +	 * Socket's owner cannot be in unloading path because there
> > +	 * must be at least one listening reference
> >  	 */
> > -	__module_get(newsock->ops->owner);
> > +	if (unlikely(!try_module_get(newsock->ops->owner)))
> > +		BUG();
> 
> rmmod --wait can make try_module_get fail even if the reference count isn't
> zero.  

OK, I though that rmmod --wait waits for refcount==0 and then changes
the state.

> But in this case, we should return an error from the accept call;
> presumably the admin really doesn't want us to keep using the module...
> 
> Thanks,
> Rusty.

-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic
