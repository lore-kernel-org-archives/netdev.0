From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 20:30:23 -0800 (PST)
Message-ID: <20051214.203023.129054759.davem@davemloft.net>
References: <20051214092228.GC18862@brahms.suse.de>
	<1134582945.8698.17.camel@w-sridhar2.beaverton.ibm.com>
	<20051215033937.GC11856@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, ak@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030388AbVLOEcn@vger.kernel.org>
To: mpm@selenic.com
In-Reply-To: <20051215033937.GC11856@waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Wed, 14 Dec 2005 19:39:37 -0800

> I think we need a global receive pool and per-socket send pools.

Mind telling everyone how you plan to make use of the global receive
pool when the allocation happens in the device driver and we have no
idea which socket the packet is destined for?  What should be done for
non-local packets being routed?  The device drivers allocate packets
for the entire system, long before we know who the eventually received
packets are for.  It is fully anonymous memory, and it's easy to
design cases where the whole pool can be eaten up by non-local
forwarded packets.

I truly dislike these patches being discussed because they are a
complete hack, and admittedly don't even solve the problem fully.  I
don't have any concrete better ideas but that doesn't mean this stuff
should go into the tree.

I think GFP_ATOMIC memory pools are more powerful than they are given
credit for.  There is nothing preventing the implementation of dynamic
GFP_ATOMIC watermarks, and having "critical" socket behavior "kick in"
in response to hitting those water marks.
