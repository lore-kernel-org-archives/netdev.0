From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: fix oops with vlan-on-top and HW_VLAN_CTAG_TX
 lowerdev
Date: Sat, 04 Jan 2014 20:13:33 -0500 (EST)
Message-ID: <20140104.201333.315186906532701163.davem@davemloft.net>
References: <20140103113904.GB28854@breakpoint.cc>
	<20140103.153352.166630160016412696.davem@davemloft.net>
	<20140104135132.GA2106@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754921AbaAEBNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 20:13:35 -0500
In-Reply-To: <20140104135132.GA2106@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 4 Jan 2014 14:51:32 +0100

> Archeology exercise #1 digs up 3b04ddde02c in linux.git, which
> creats header_ops->rebuild, from the old  dev->rebuild_header.
> 
> Exercise #2 then finds commit 275513d2e1c78 in netdev-vger-cvs.git tree.
> Quote from commit message:
> 
>         - dev->rebuild_header WILL DISAPPEAR. All the code
>           relying on its existance is wrong, though still works.
> 
> Alexey calling from 1997 ;-)

These protocols which use the broken ARP ops are special, the
problem is that they do things like send packets out when their
header ops are invoked.

It's non-trivial to undo this design, and these aren't easy protocols
to test.

That's why we've had this compat stuff for them for more than a
decade.
