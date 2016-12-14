From: Christoph Lameter <cl@linux.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Date: Wed, 14 Dec 2016 11:00:12 -0600 (CST)
Message-ID: <alpine.DEB.2.20.1612141059020.20959@east.gentwo.org>
References: <20161205153132.283fcb0e@redhat.com> <20161212083812.GA19987@rapoport-lnx> <20161212104042.0a011212@redhat.com> <20161212141433.GB19987@rapoport-lnx> <584EB8DF.8000308@gmail.com> <20161212181344.3ddfa9c3@redhat.com> <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com> <8aea213f-2739-9bd3-3a6a-668b759336ae@stressinduktion.org>
Content-Type: text/plain; charset=US-ASCII
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-mm <linux-mm@kvack.org>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        =?ISO-8859-15?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
        "Karlsson, Magnus" <magnus.karlsson@intel.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Kalman Meth <METH@il.ibm.com>,
        Vladislav Yasevich <vyasevich@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-07v.sys.comcast.net ([69.252.207.39]:57729 "EHLO
        resqmta-ch2-07v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932352AbcLNRAQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 12:00:16 -0500
In-Reply-To: <8aea213f-2739-9bd3-3a6a-668b759336ae@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Dec 2016, Hannes Frederic Sowa wrote:

> > Interesting.  So you even imagine sockets registering memory regions
> > with the NIC.  If we had a proper NIC HW filter API across the drivers,
> > to register the steering rule (like ibv_create_flow), this would be
> > doable, but we don't (DPDK actually have an interesting proposal[1])
>
> On a side note, this is what windows does with RIO ("registered I/O").
> Maybe you want to look at the API to get some ideas: allocating and
> pinning down memory in user space and registering that with sockets to
> get zero-copy IO.

Yup that is also what I think. Regarding the memory registration and flow
steering for user space RX/TX ring please look at the qpair model
implemented by the RDMA subsystem in the kernel. The memory semantics are
clearly established there and have been in use for more than a decade.
