From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
 else")
Date: Tue, 31 Aug 2004 12:24:34 +0200 (CEST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <Pine.LNX.4.61.0408311145580.12063@filer.marasystems.com>
References: <20040830201957.GY5824@sunbeam.de.gnumonks.org>
	<20040830140729.7309ecc0.davem@davemloft.net>
	<20040831013841.GA5824@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, rusty@rustcorp.com.au,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040831013841.GA5824@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Aug 2004, Harald Welte wrote:

> and it apparently happens in a lot of 'typical' setups where you have a
> masqueraded DSL line with dynamic ip address for bulk traffic, and
> fwmark-based routing through one or more tunnel interfaces, optionally
> with different masqerading/SNAT.

Should only happen if the routing is screwed up, in principle..

> Also, the MASQUERADE lookup (obviously) has no more saddr in the lookup,
> that's another difference from the 'original' lookup.

This is a possible reason why it screws up for such many people? By not 
including the source IP you make the route lookup for determining the 
MASQUERADE information very different from the route lookup when 
forwardning the packet.

I think it would for most make more sense that the source IP assignment is 
based on routing using the original source address as key.

What I don't get is why MASQUERADE needs to do a route lookup at all. 
Isn't the traffic already routed at this point, and shouldn't it simply 
use the source IP of the current selected route or the interface primary 
IP of no source IP set in the route?

> That is the presumption I am about to challenge.  Is the 'original'
> interface really the one we want in this case?

If there is policy routing saying that packets with a given source 
should go out another interface my opinion is that they should.

I have been using SNAT in quite many complex routing setups and so far has 
not run into any situation where routing gets wrong in an unmanageable and 
unintuitive manner due to SNAT. MASQUERADE should not be more complex.

Regards
Henrik
