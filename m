From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast
	messages
Date: Wed, 15 Apr 2009 10:22:08 -0400
Message-ID: <20090415142208.GB21448@hmsreliant.think-freely.org>
References: <alpine.DEB.1.10.0904131704120.3517@qirst.com> <20090414132551.GC14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904140946130.5712@qirst.com> <20090414182731.GD14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141447310.30596@qirst.com> <20090414204445.GB17196@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141740280.3973@qirst.com> <20090415110714.GA21448@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904150841550.10217@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:32992 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbZDOOWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 10:22:19 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904150841550.10217@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2009 at 08:51:35AM -0400, Christoph Lameter wrote:
> On Wed, 15 Apr 2009, Neil Horman wrote:
> 
> > > How are you going to do this?
> > I'm going to write each application to use 2 sockets, one bound to each
> > multicast group.  Thats the way it works now.  I think you missed the obvious in
> > your construction of this example.
> 
> Ok it could be done with binding. But you would need 3 sockets. One per MC
> groups bound to a MC group each and then one for the replies (hmmm...
> looks like you could use SO_BINDTODEVICE on one socket to get around the
Depending on your setup, 2 is perfectly sufficient.  In fact 1 can be sufficient
if you want to filter in your application, but we've been over that.

> third one --there is even an exception case for this in inet_bind causing
> more weird semantics-- but then the application needs to know the device
> name of the NIC, argh)
Of course it does, but thats zero incremental cost, since you need to know the
device name anyway, when specifying the ifindex to the join request.

> > > Its trivial to do with this patch and one
> > > socket in each process listening to port 4711 that subscribes to the
> > > necessary multicast groups.
> > Its trivial without the patch as well.
> 
> I do not see how you can justify making such a statement.
> 
I find it justified because I don't see an application using 2 or 3 sockets and a poll or
select call as anything more than trivial.  If you find that to be non-trivial,
perhaps a refresher programming course might be in order for you?

> > It boils down to this:  This is the way multicast subscriptions have worked in
> > bsd, linux, and presumably various other unix and non-unix operating systems for
> > lord only knows how long.  Provide some documentation that shows its in
> > violation of a newer standard, or that it is common practice to behave
> > differently on another OS (such that including this directive would make porting
> > easier).  As it stands currently, this patch only serves to create a crutch to
> > perpetuate misundersandings about how the behavior currently works.
> 
> The way things work is counterintuitive and leads to weird code constructs
> with the application having to manage multiple sockets because weird
> semantics have developed over the years.

The way things work is counterintuitive to _you_ (is it was to me a few months
ago).  That asside, I came to understand how this actually works, how it has
worked for decades, and how programmers have successfully written applications
that use this model over that time period.  Can we modify the model?  Sure.
Should we?  I certainly don't see any need, given that it does little except
change the model.  For those who understand it, its compltely useless.  I'm
willing to concede that I'm wrong, but not without some modicum of evidence that
this change will benefit existing applications.  If some other operating system
adheres to the model you expect it to, perhaps this has legs, but I don't know
of any that do.  The current model, even if counter intuitive, is well defined,
well understood, and documented.  I fail to see how adding an alternate,
undocumented model (that may itself be counterintuitive to all the developers
who have developed under the current model) adds anything significant.

Neil

