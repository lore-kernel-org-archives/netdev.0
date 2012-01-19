From: David Lamparter <equinox@diac24.net>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 20:25:41 +0100
Message-ID: <20120119192541.GM2262734@jupiter.n2.diac24.net>
References: <201201191207.10207.hans.schillstrom@ericsson.com>
 <20120119.124002.1964667767933832927.davem@davemloft.net>
 <20120119190114.GL2262734@jupiter.n2.diac24.net>
 <20120119.140621.817165404586593441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: equinox@diac24.net, hans.schillstrom@ericsson.com,
	netdev@vger.kernel.org, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:54456 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932652Ab2ASTZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 14:25:50 -0500
Content-Disposition: inline
In-Reply-To: <20120119.140621.817165404586593441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2012 at 02:06:21PM -0500, David Miller wrote:
> From: David Lamparter <equinox@diac24.net>
> > On Thu, Jan 19, 2012 at 12:40:02PM -0500, David Miller wrote:
> >> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> >> > Closing of a namespace (container) can be delayed by ~ 2 minutes 
> >> > due to tcp timers ex tcp time wait (and of cource other things too).
> >> > 
> >> > I think there should be some kind of "forced close" of the Network stack
> >> > in ex free_nsproxy() 
> >> 
> >> I think this is unwise.
> >> 
> >> Keeping the timewait sockets around is necessary to absorb any lingering
> >> packets in the network meant for those sockets.
> >> 
> >> If you truncate this activity, and then try to create another socket with
> >> the same ID you'll run into the very problems time-wait is meant to
> >> solve.
> > 
> > A network namespace is for practical matters a separate host on the
> > network. Killing the namespace therefore is akin to shutting down that
> > host, which on a real metal host doesn't wait for timewait sockets
> > either.
> > 
> > Creating a socket with the same parameters would actually require
> > installing a network environment similar to the closed namespace first;
> > if an user really does that he can reasonably anticipate the same issues
> > as arise from removing a host from the network and giving its address to
> > another host.
> 
> The assumption is that the address is moving, which might not be true.

I don't understand what you mean, what address may not be moving?

We're talking about dropping a netns. All of its addresses disappear,
all of its soft devices disappear. Its hard devices fall back into the
init namespace, is that what you're referring to?

Or are you referring to the case where the network namespace is
recreated immediately after? That would be akin to a reboot, and again a
physical box wouldn't wait for timewait sockets...
