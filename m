From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Fri, 17 Aug 2007 23:44:05 -0700 (PDT)
Message-ID: <20070817.234405.66176298.davem@davemloft.net>
References: <adafy2hyc04.fsf@cisco.com>
	<20070817.170033.63993876.davem@davemloft.net>
	<adatzqxwh56.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adatzqxwh56.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 17 Aug 2007 22:23:01 -0700

> Also, looking at the complexity and bug-fixing effort that go into
> making TSO work vs the really pretty small gain it gives also makes
> part of me wonder whether the noble proclamations about
> maintainability are always taken to heart.

The cpu and bus utilization improvements of TSO on the sender side are
more than significant.  Ask anyone who looks closely at this.

For example, as part of his batching work Krisha Kumar has been
posting lots of numbers lately on the netdev list, I'm sure he can
post more specific numbers comparing the current stack in the case of
TSO disabled vs. TSO enabled if that is what you need to see how
beneficial TSO in fact is.

If TSO is such a lose why does pretty much every ethernet chip vendor
implement it in hardware?  If you say it's just because Microsoft
defines TSO in their NDI, that's a total cop-out.  It really does help
performance a lot.  Why did the Xen folks bother making generic
software TSO infrastructure for the kernel for the benefit of their
virtualization network device?  Why would someone as bright as Herbert
Xu even bother to implement that stuff if TSO gives a "pretty small
gain"?

Similarly for LRO and this isn't defined in NDI at all.  Vendors are
going so far as to put full flow tables in their chips in order to do
LRO better.

Using the bugs and issues we've run into while implementing TSO as
evidence there is something wrong with it is a total straw man.  Look
how many times the filesystem page cache has been rewritten over the
years.

Use the TSO problems as more of an example of how shitty a programmer
I must be. :)

Just be realistic and accept that RDMA is a point in time solution,
and like any other such technology takes flexibility away from users.

Horizontal scaling of cpus up to huge arity cores, network devices
using large numbers of transmit and receive queues and classification
based queue selection, are all going to work to make things like RDMA
even more irrelevant than they already are.

If you can't see that this is the future, you have my condolences.
Because frankly, the signs are all around that this is where things
are going.

The work doesn't belong in these special purpose devices, they belong
in the far-end-node compute resources, and our computers are getting
more and more of these general purpose compute engines every day.
We will be constantly moving away from specialized solutions and
towards those which solve large classes of problems for large groups
of people.
