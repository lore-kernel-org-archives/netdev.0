From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Wed, 10 Oct 2007 16:04:54 -0700 (PDT)
Message-ID: <20071010.160454.25158026.davem@davemloft.net>
References: <20070809.145534.102938208.davem@davemloft.net>
	<470AA729.2050009@opengridcomputing.com>
	<470D3D93.2020606@ichips.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: mshefty@ichips.intel.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <470D3D93.2020606@ichips.intel.com>
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

From: Sean Hefty <mshefty@ichips.intel.com>
Date: Wed, 10 Oct 2007 14:01:07 -0700

> > The hack to use a socket and bind it to claim the port was just for 
> > demostrating the idea.  The correct solution, IMO, is to enhance the 
> > core low level 4-tuple allocation services to be more generic (eg: not 
> > be tied to a struct sock).  Then the host tcp stack and the host rdma 
> > stack can allocate TCP/iWARP ports/4tuples from this common exported 
> > service and share the port space.  This allocation service could also be 
> > used by other deep adapters like iscsi adapters if needed.
> 
> Since iWarp runs on top of TCP, the port space is really the same. 
> FWIW, I agree that this proposal is the correct solution to support iWarp.

But you can be sure it's not going to happen, sorry.

It would mean that we'd need to export the entire TCP socket table so
then when iWARP connections are created you can search to make sure
there is not an existing full 4-tuple that is the same.

It is not just about local TCP ports.

iWARP needs to live in it's seperate little container and not
contaminate the rest of the networking, this is the deal.  Any
suggested such change which breaks that deal will be NACK'd by all of
the core networking developers.
