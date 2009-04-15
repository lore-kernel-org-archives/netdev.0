From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast
 messages
Date: Wed, 15 Apr 2009 08:51:35 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904150841550.10217@qirst.com>
References: <alpine.DEB.1.10.0904131704120.3517@qirst.com> <20090414132551.GC14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904140946130.5712@qirst.com> <20090414182731.GD14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141447310.30596@qirst.com>
 <20090414204445.GB17196@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141740280.3973@qirst.com> <20090415110714.GA21448@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:40983 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbZDOM61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 08:58:27 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1AB2982C3F8
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 09:08:13 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id lyhIZEBh6XhI for <netdev@vger.kernel.org>;
	Wed, 15 Apr 2009 09:08:07 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 06BEA82C3F2
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 09:08:07 -0400 (EDT)
In-Reply-To: <20090415110714.GA21448@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Apr 2009, Neil Horman wrote:

> > How are you going to do this?
> I'm going to write each application to use 2 sockets, one bound to each
> multicast group.  Thats the way it works now.  I think you missed the obvious in
> your construction of this example.

Ok it could be done with binding. But you would need 3 sockets. One per MC
groups bound to a MC group each and then one for the replies (hmmm...
looks like you could use SO_BINDTODEVICE on one socket to get around the
third one --there is even an exception case for this in inet_bind causing
more weird semantics-- but then the application needs to know the device
name of the NIC, argh)

> > Its trivial to do with this patch and one
> > socket in each process listening to port 4711 that subscribes to the
> > necessary multicast groups.
> Its trivial without the patch as well.

I do not see how you can justify making such a statement.

> It boils down to this:  This is the way multicast subscriptions have worked in
> bsd, linux, and presumably various other unix and non-unix operating systems for
> lord only knows how long.  Provide some documentation that shows its in
> violation of a newer standard, or that it is common practice to behave
> differently on another OS (such that including this directive would make porting
> easier).  As it stands currently, this patch only serves to create a crutch to
> perpetuate misundersandings about how the behavior currently works.

The way things work is counterintuitive and leads to weird code constructs
with the application having to manage multiple sockets because weird
semantics have developed over the years.
