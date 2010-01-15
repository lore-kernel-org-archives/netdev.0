From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe: [RFC] [PATCH] Fix return of invalid txq
Date: Fri, 15 Jan 2010 01:00:20 -0800
Message-ID: <1263546020.2038.7.camel@localhost>
References: <20100115053117.31513.82775.sendpatchset@krkumar2.in.ibm.com>
	 <F86E8680A7D9D74A99DC6345E35A692950158650@orsmsx503.amr.corp.intel.com>
	 <20100115.004456.15627093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "krkumar2@in.ibm.com" <krkumar2@in.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8930 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753773Ab0AOJAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2010 04:00:21 -0500
In-Reply-To: <20100115.004456.15627093.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-01-15 at 00:44 -0800, David Miller wrote:
> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Thu, 14 Jan 2010 23:58:17 -0800
> 
> > I've been trying to find time to add something like igb has, with a
> > tiny Tx lookup table that maps CPUs into a smaller set of Tx queues.
> 
> Why do you need "tables"?  Just modulo the it, with whatever
> optimizations you can come up with.
> 
> Or do we not have enough data references in the TX path already?
> :-/
> 
> I would suggest getting rid of the table in IGB too.
> 
> Either "tables" are a good idea (I think they definitely are not)
> or they are not.  And whatever the decision is we should do it
> consistently.  net/core/dev.c doesn't use tables, it does the
> subtraction modulo thing like Krishna does.

What I've been thinking of is more for the NUMA allocations per port.
If we have, say 2 sockets, 8 cores a piece, then we have 16 CPUs.  If we
assign a port to socket 0, I think the best use of resources is to
allocate 8 Rx/Tx queues, one per core in that socket.  If an application
comes from the other socket, we can have a table to map the other 8
cores from that socket into the 8 queues, instead of piling them all
into one of the Tx queues.

Cheers,
-PJ

