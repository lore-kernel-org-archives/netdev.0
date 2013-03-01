From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH v4 1/9] rdma/cm: define native IB address
Date: Fri, 1 Mar 2013 03:49:30 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A823736F35600F@ORSMSX101.amr.corp.intel.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
 <1358891797-14625-2-git-send-email-sean.hefty@intel.com>
 <1828884A29C6694DAF28B7E6B8A8237368B99D59@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David Miller (davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org)" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A8237368B99D59-P5GAC/sN6hmkrb+BlOpmy7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > Define AF_IB and sockaddr_ib to allow the rdma_cm to use native IB
> > addressing.
> >
> > Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > ---
> >  include/linux/socket.h |    2 +
> >  include/rdma/ib.h      |   89
> ++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 91 insertions(+), 0 deletions(-)
> >  create mode 100644 include/rdma/ib.h
> >
> > diff --git a/include/linux/socket.h b/include/linux/socket.h
> > index 9a546ff..17a33f7 100644
> > --- a/include/linux/socket.h
> > +++ b/include/linux/socket.h
> > @@ -167,6 +167,7 @@ struct ucred {
> >  #define AF_PPPOX	24	/* PPPoX sockets		*/
> >  #define AF_WANPIPE	25	/* Wanpipe API Sockets */
> >  #define AF_LLC		26	/* Linux LLC			*/
> > +#define AF_IB		27	/* Native InfiniBand address	*/
> 
> ...
> 
> > diff --git a/include/rdma/ib.h b/include/rdma/ib.h
> 
> ...
> 
> > +struct sockaddr_ib {
> > +	unsigned short int	sib_family;	/* AF_IB */
> > +	__be16			sib_pkey;
> > +	__be32			sib_flowinfo;
> > +	struct ib_addr		sib_addr;
> > +	__be64			sib_sid;
> > +	__be64			sib_sid_mask;
> > +	__u64			sib_scope_id;
> > +};
> 
> Dave/Roland/anyone, is there any feedback on this approach?

ping...

Seriously, there is a need to establish connections using native IB GIDs.  It is preferable to add this functionality to the rdma_cm.  Although the ib_cm can exchange IB CM messages based on GIDs, the rdma_cm is the only interface that provides applications with dynamic service IDs, path record queries, and usable multicast support. 

The rdma_cm uses sockaddr for addressing information.  The sockaddr_ib structure is defined within the RDMA tree, but I believe that the address family value belongs in socket.h.  This helps to avoid any future conflicts.  However, I can change the rdma_cm to use an internal enum for address values if there is an objection.

sockaddr_ib/AF_IB is usable with any IB network card.  It allows an application to establish connections over IB without IBoIP being present, which is a real need.  It also allows an application to use out of band mechanisms for discovering remote GIDs.  Such mechanisms are needed to work through IP load balancing software and for MPI scalability.

I'm not trying to be impatient, but it's been 3 years... 

- Sean
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
