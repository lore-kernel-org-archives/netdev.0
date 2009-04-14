From: Christoph Lameter <cl@linux.com>
Subject: Re: Kernel sends multicast groups to sockets that did not subscribe
 to the MC group
Date: Tue, 14 Apr 2009 16:16:31 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904141608220.30596@qirst.com>
References: <alpine.DEB.1.10.0904131704120.3517@qirst.com> <20090414132551.GC14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904140946130.5712@qirst.com> <20090414182731.GD14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141424440.30596@qirst.com>
 <20090414200139.GA17196@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:41359 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755913AbZDNUXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 16:23:52 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6E57C82C354
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 16:33:33 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FvwMI2IorVXZ for <netdev@vger.kernel.org>;
	Tue, 14 Apr 2009 16:33:27 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C228082C4E3
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 16:32:56 -0400 (EDT)
In-Reply-To: <20090414200139.GA17196@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Apr 2009, Neil Horman wrote:

> Lets be clear here, when you say, bind, are you referring to the bind call
> specifically?  or the setsockopt(IP_ADD_MEMBERSHIP, ... ) call?  I'm referring
> to the former.  From your initial description, you're referring to the latter.
> If you check inet_bind, you'll note that the sockets rcv_saddr is set to the
> bound address, which is then later used in udp_v4_mcast_next to filter on which
> sockets should receive which frames, so by binding (via the bind syscall), you
> can make a socket filter which mcast address it receives.  I'm fairly certain in
> your test, you're referring to membership management, via IP_ADD_MEMBERSHIP,
> which is different from bind.

We are both referring to the bind call. Which does not make sense in this
contect since we want to filter multicast traffic to a certain multicast
address. This is *not* to be confused with the interface address.

> See above.  It has everything to do with how bind works.  If you bind to
> INADDR_ANY (which by the way is the default binding if you don't call bind on a
> socket from your application), you are implicitly bound to receive frames from
> all destination addresses in the system, which is why you get the behavior you
> are seeing.  If you want to restrict which multicast addresses you recieve, bind
> to them.

There is only a single multicast address you can "bind" to here. What you
are suggesting here is dicsouraged because traffic you will then send out
from the socket will have as its origin the multicast address.

> If you don't yet understand what bind has to do with how this works, please read
> above.

You are messing around with binding becasue the multicast filtering
does not work?

> > One could envison having two processes that open the same socket/port and
> > coordinate: The first joins the multicast groups and then continues in a
> > monitoring role whereas the second actually processes the data. But then
> > the data is forwarded to both processes and one of them is not processing
> > it. So its fundamentally bad behavior. I would even suggest to make the
> > socket based filtering the default (as in other OSes).
> >
> Thats a poorly written application.  I refer you again to the implementation of
> bind (see inet_bind and udp_v4_mcast_next for details of its inner workings)

Which you should not abuse for multicast filtering. These are hacks to
deal with the problem that the socket multicast lists are not used for
filtering.
