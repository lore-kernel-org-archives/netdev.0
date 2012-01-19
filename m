From: David Lamparter <equinox@diac24.net>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 22:03:52 +0100
Message-ID: <20120119210352.GA3347849@jupiter.n2.diac24.net>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net>
 <20120119.143105.735366189369504929.davem@davemloft.net>
 <20120119195349.GN2262734@jupiter.n2.diac24.net>
 <20120119.152752.318442465605898328.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: equinox@diac24.net, hans.schillstrom@ericsson.com,
	netdev@vger.kernel.org, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:41495 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932818Ab2ASVEC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 16:04:02 -0500
Content-Disposition: inline
In-Reply-To: <20120119.152752.318442465605898328.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2012 at 03:27:52PM -0500, David Miller wrote:
> From: David Lamparter <equinox@diac24.net>
> > On Thu, Jan 19, 2012 at 02:31:05PM -0500, David Miller wrote:
> >> Then if a new netns is created that tries to reuse the address used by
> >> the mini-netns which hasn't cleared yet, you give -EAGAIN until all
> >> the timewaits expire.
> > 
> > The effect of this is that you end up being unable to reboot lxc based
> > virtualised hosts without waiting 2 minutes for the TCP timers to
> > expire. That sounds completely unacceptable to me.
> 
> All you are saying to me is that we are on a trajectory to major problems
> if it becomes pervasive that time-wait gets cancelled out and addresses
> then get reused so quickly.

On the funny side, RFC 793 page 28 actually states under "Knowing When
to Keep Quiet" that
  "To be sure that a TCP does not create a segment that carries a
  sequence number which may be duplicated by an old segment remaining in
  the network, the TCP must keep quiet for a maximum segment lifetime
  (MSL) before assigning any sequence numbers upon starting up or
  recovering from a crash in which memory of sequence numbers in use was
  lost. For this specification the MSL is taken to be 2 minutes."

Let's implement that, I bet people will love a 2 minute wait on TCP
connections after booting :-)


-David
