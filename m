From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: [ofa-general] Re: Re: [PATCH V3 0/7] net/bonding: ADD IPoIB support
	for	the bonding driver
Date: Tue, 31 Jul 2007 17:04:36 +0300
Message-ID: <20070731140436.GA16015@mellanox.co.il>
References: <46ADDB89.5030601@voltaire.com> <adaejipr3l5.fsf@cisco.com>
	<46AF3CA8.6050201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>, fubar@us.ibm.com,
	davem@davemloft.net, general@lists.openfabrics.org
To: Moni Shoua <monisonlists@gmail.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <46AF3CA8.6050201@gmail.com>
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

> Quoting Moni Shoua <monisonlists@gmail.com>:
> Subject: Re: Re: [PATCH V3 0/7] net/bonding: ADD IPoIB support for?the bonding driver
> 
> Roland Dreier wrote:
> >  > 1. When bonding enslaves an IPoIB device the bonding neighbor holds a 
> >  > reference to a cleanup function in the IPoIB drives. This makes it unsafe to 
> >  > unload the IPoIB module if there are bonding neighbors in the air. So, to 
> >  > avoid this race one must unload bonding before unloading IPoIB. 
> > 
> > I think we really want to resolve this somehow.  Getting an oops by
> > doing "modprobe -r ipoib" isn't that friendly.
> > 
> You are right and we want to resolve that.
> One way is to clean the neigh destructor function from all IPoIB neighs.
> The other way is to prevent ipoib unload if device is a slave or is referenced from 
> somewhere else.
> 
> I guess I would like an advice here.

I had this idea:


Maybe we could use hard_header_cache/header_cache_update methods instead of
neighbour cleanup calls.

To do this, it is possible that we'll have to switch from storing pointers
inside the neighbour to keeping an index there, but I expect the
performance impact to be minimal.

As a result, bonding would not have to copy pointers into ipoib module
and module removal would get fixed.

-- 
MST
