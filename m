From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Thu, 30 Jan 2014 23:44:11 +0100
Message-ID: <20140130224411.GG25336@order.stressinduktion.org>
References: <20140118191107.GA21979@sesse.net> <20140119181806.GC16462@order.stressinduktion.org> <20140120184025.GA19972@sesse.net> <20140130104709.GA21178@sesse.net> <20140130180304.GA3793@plex.lan> <20140130181229.GA32245@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47952 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbaA3WoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 17:44:13 -0500
Content-Disposition: inline
In-Reply-To: <20140130181229.GA32245@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 07:12:29PM +0100, Steinar H. Gunderson wrote:
> On Thu, Jan 30, 2014 at 04:08:11PM -0200, Flavio Leitner wrote:
> > No special multicast route, so it should go out on em1/default route.
> 
> Well, that's not really relevant for my bug then, is it? My problem is that
> it goes out on the default unicast route, whereas it shouldn't.

Hmm, it looks to me that Flavio showed that it should actually work
correctly.

> > Maybe your application is using wrong values to IP_MULTICAST_IF?
> > strace and /proc/net/igmp as suggested might help you find out.
> 
> This goes for at least vlc+mplayer+xbmc. I don't think they would all be
> buggy in the same way? (Actually I don't think any of them set
> IP_MULTICAST_IF.)

The routing lookup is done at IP_ADD_MEMBERSHIP time. I really wonder why you
have routed the 239.0.0.0/8 range to eth0.11. It seems to me that the kernel
does what you told it to do. ;)

multicast flag on ip route is just used for multicast forwarding and does not
matter for local multicast. Also if we find unicast route first (more
specific) kernel does not do backtracking if destination is in multicast
scope.

Greetings,

  Hannes
