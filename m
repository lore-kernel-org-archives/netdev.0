From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast
	messages
Date: Wed, 15 Apr 2009 07:07:14 -0400
Message-ID: <20090415110714.GA21448@hmsreliant.think-freely.org>
References: <alpine.DEB.1.10.0904131704120.3517@qirst.com> <20090414132551.GC14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904140946130.5712@qirst.com> <20090414182731.GD14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141447310.30596@qirst.com> <20090414204445.GB17196@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141740280.3973@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47273 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbZDOLHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:07:23 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904141740280.3973@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2009 at 05:45:58PM -0400, Christoph Lameter wrote:
> On Tue, 14 Apr 2009, Neil Horman wrote:
> 
> > That said, I still disagree with the addition of this switch, as its
> > superfolous.  Programatically an application can do what you want without this
> > change already .If you provide me with the test application that you've been working with, I can
> > demonstrate exactly how.
> 
> Ok. First applications listens to multicast groups A and B. Second one
> uses C and D. All use a port 4711 for communication which is the
> standard for a certain application. Both applications are very latency
> sensitive. You do not want the data to be duplicated into the user space
> of both processes.
> 
> Both processes need to reply to messages on the
> multicast groups. The receiver always needs the source IP address for
> authentication otherwise messages are ignored
> 
> How are you going to do this? 
I'm going to write each application to use 2 sockets, one bound to each
multicast group.  Thats the way it works now.  I think you missed the obvious in
your construction of this example.

> Its trivial to do with this patch and one
> socket in each process listening to port 4711 that subscribes to the
> necessary multicast groups. 
Its trivial without the patch as well.

> Plus one the problem is that some of the
> applications here are only available in binary form and they were naively
> coded assuming that the socket layer would not need exotic tricks to
> convince it to do the right thing.
What?  If you have binary only software thats written for Linux and it
malfunctions,  This has been the accepted and standard multicast behavior on
Linux and various other unicies for decades.  What you are describing is a
vendor bug in your application, something you need to either contact the vendor
about, or find a new vendor.  They made an application based on an assumption,
and their assumption was wrong, they need to fix it.  We could do them a favor,
I suppose, but I don't see why.

It boils down to this:  This is the way multicast subscriptions have worked in
bsd, linux, and presumably various other unix and non-unix operating systems for
lord only knows how long.  Provide some documentation that shows its in
violation of a newer standard, or that it is common practice to behave
differently on another OS (such that including this directive would make porting
easier).  As it stands currently, this patch only serves to create a crutch to
perpetuate misundersandings about how the behavior currently works.

Neil
