From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Fri, 23 Nov 2007 02:36:22 +0100
Message-ID: <200711230236.22759.ak@suse.de>
References: <20071122343.446909000@suse.de> <20071122110545.GA4552@infradead.org> <200711231125.12832.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37879 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753070AbXKWBlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 20:41:32 -0500
In-Reply-To: <200711231125.12832.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 23 November 2007 01:25, Rusty Russell wrote:
> On Thursday 22 November 2007 22:05:45 Christoph Hellwig wrote:
> > On Thu, Nov 22, 2007 at 02:56:22PM +1100, Rusty Russell wrote:
> > >     This is an interesting idea, thanks for the code!  My only question
> > > is whether we can get most of this benefit by dropping the indirection
> > > of namespaces and have something like "EXPORT_SYMBOL_TO(sym, modname)"?
> > >  It doesn't work so well for exporting to a group of modules, but that
> > > seems a reasonable line to draw anyway.
> >
> > I'd say exporting to a group of modules is the main use case.  E.g. in
> > scsi there would be symbols exported to transport class modules only
> > or lots of the vfs_ symbols would be exported only to stackable
> > filesystems or nfsd.
>
> That's my point.  If there's a whole class of modules which can use a
> symbol, why are we ruling out external modules? 

The point is to get cleaner interfaces. Anything which is kind of internal
should only be used by closely related in tree modules which can be updated. 
Point of is not to be some kind of license enforcer or similar, there 
are already other mechanisms for that. Just to get the set of really
public kernel interfaces down to a manageable level.

But I still think exporting only to a single module would be to limiting 
for this case even. It would work for the TCP<->ipv6.ko post child,
but not for some of the other networking cases where it makes sense.

> If that's what you want, 
> why not have a list of permitted modules compiled into the kernel and allow
> no others?

That would not make the relationship explicit, which would not further
the goal.

-Andi
