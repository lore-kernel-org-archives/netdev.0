From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP path MTU discovery
Date: Sun, 4 Apr 2010 12:25:20 +0200
Message-ID: <20100404102520.GB18855@one.firstfloor.org>
References: <1269561751.2891.8.camel@ilion> <877how25kx.fsf@basil.nowhere.org> <4BB0DCF6.9020401@hp.com> <1270078984.2389.33.camel@ilion> <20100401005539.GZ20695@one.firstfloor.org> <1270186918.2119.27.camel@ilion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Rick Jones <rick.jones2@hp.com>,
	netdev@vger.kernel.org
To: Glen Turner <gdt@gdt.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:59282 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab0DDKZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 06:25:21 -0400
Content-Disposition: inline
In-Reply-To: <1270186918.2119.27.camel@ilion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 02, 2010 at 04:11:58PM +1030, Glen Turner wrote:
> On Thu, 2010-04-01 at 02:55 +0200, Andi Kleen wrote:
> > > What we need is an API for an instant notification that a ICMP Packet
> > > Too Big message has arrived concerning the socket.
> > 
> > That already exists of course: IP_RECVERR
> 
> Hi Andi,
> 
> So what should I code?  The suggested EMSGSIZE or your suggestion
> of grabbing all returning ICMP and parsing it?  Noting that the

You don't need to parse any ICMPs, the kernel does that for you. 
See the documentation of IP_RECVERR in ip(7). The MTU is in ee_info

First you need to enable path mtu discovery for the socket
using IP_MTU_DISCOVER.

So you can either keep track of the MTU yourself based on extended
errors coming out of IP_RECVERR, or ask the kernel using IP_MTU when
the socket is connected or simply lower when you see a EMSGSIZE. It's also 
possible to do this with a dummy socket that gets connected/unconnected too.

> second choice is pretty ugly.  That both seem specific to Linux is
> frustrating, but that is life -- adding support for an operating
> system seems to inevitably add #ifdefs for this sort of code.

Well when the other OS see the need they will hopefully add similar
interfaces, with some luck even compatible to the ones in Linux.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
