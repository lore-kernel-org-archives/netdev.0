From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast
 groups
Date: Tue, 12 Jul 2011 13:36:43 +0200
Message-ID: <20110712113643.GC616804@jupiter.n2.diac24.net>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
 <CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
 <20110711082755.0b38a15a@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Carter <ncarter100@gmail.com>, netdev@vger.kernel.org,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	David Lamparter <equinox@diac24.net>, davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:52919 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752964Ab1GLLgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 07:36:55 -0400
Content-Disposition: inline
In-Reply-To: <20110711082755.0b38a15a@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 08:27:55AM -0700, Stephen Hemminger wrote:
> On Sun, 10 Jul 2011 17:04:30 +0100
> Nick Carter <ncarter100@gmail.com> wrote:
> 
> > Updated diffs so they apply to net-next (Original diffs were based off 2.6.38).
> > 
> > Any chance of getting these diffs applied?  The default behaviour of
> > the bridge code is unchanged.  They solve the problem of
> > authenticating a virtual 802.1x supplicant machine against an external
> > 802.1X authenticator.  It is also a general solution that allows the
> > forwarding of any combination of the IEEE 802 local multicast groups.
> > 
> > Signed-off-by: Nick Carter <ncarter100@gmail.com>
> > Reviewed-by: David Lamparter <equinox@diac24.net>
> 
> I am still undecided on this. Understand the need, but don't like idea
> of bridge behaving in non-conforming manner. Will see if IEEE 802 committee
> has any input.

The patch doesn't make the bridge behave nonconformant. The default mask
is 0, which just keeps the old behaviour.

If you set the lowest 3 bits, yes, you can break your network. But so
does enabling proxy_arp in most cases. And there are reasonable use
cases for it, both 802.1X forwarding and fully-transparent* packet
capture bridges benefit from it. And the latter is something I wouldn't
wish to move to userspace either.

Maybe we should add a warning if the lowest 3 bits are set, like
"you have enabled forwarding of STP/Pause/Bond frames. This can
thoroughly break your network."

* excl. pause frames, sadly - those get eaten by hw/driver...

> Also, don't want to build more knobs in with sysfs that are per-bridge.
> Eventually, the plan is to make all the setting per-port with sysctl's
> like IPv6.

This setting doesn't make sense per-port IMHO. Also, sysctl?!


-David

