From: Moni Shoua <monisonlists@gmail.com>
Subject: Re: [ofa-general] Re: [PATCH V3 0/7] net/bonding: ADD IPoIB support
	for	the bonding driver
Date: Tue, 31 Jul 2007 16:44:08 +0300
Message-ID: <46AF3CA8.6050201@gmail.com>
References: <46ADDB89.5030601@voltaire.com> <adaejipr3l5.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, davem@davemloft.net, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adaejipr3l5.fsf@cisco.com>
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

Roland Dreier wrote:
>  > 1. When bonding enslaves an IPoIB device the bonding neighbor holds a 
>  > reference to a cleanup function in the IPoIB drives. This makes it unsafe to 
>  > unload the IPoIB module if there are bonding neighbors in the air. So, to 
>  > avoid this race one must unload bonding before unloading IPoIB. 
> 
> I think we really want to resolve this somehow.  Getting an oops by
> doing "modprobe -r ipoib" isn't that friendly.
> 
You are right and we want to resolve that.
One way is to clean the neigh destructor function from all IPoIB neighs.
The other way is to prevent ipoib unload if device is a slave or is referenced from 
somewhere else.

I guess I would like an advice here.
> Also, what happened to the problem of having an address handle
> belonging to the wrong device on bond failover?  Did you figure out a
> way to fix that one?
This is what patch 2 handles.
> 
>  - R.
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
> 
> To unsubscribe, please visit http://openib.org/mailman/listinfo/openib-general
> 
