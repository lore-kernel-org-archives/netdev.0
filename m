From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCH net-next 2/2] cxgb4/iw_cxgb4: Doorbell Drop Avoidance Bug Fixes
Date: Wed, 26 Mar 2014 10:58:35 -0500
Message-ID: <007101cf490c$3ec7cb30$bc576190$@opengridcomputing.com>
References: <1394814128-8815-1-git-send-email-hariprasad@chelsio.com>	 <1394814128-8815-3-git-send-email-hariprasad@chelsio.com> <1395848977.3297.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: "'Yann Droneaud'" <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1395848977.3297.15.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Language: en-us
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> > +		uresp.status_page_size = PAGE_SIZE;
> > +
> > +		spin_lock(&context->mmap_lock);
> > +		uresp.status_page_key = context->key;
> > +		context->key += PAGE_SIZE;
> > +		spin_unlock(&context->mmap_lock);
> > +
> 
> Is it really necessary to spinlock here since context is local to the
> function ?
> 

You're correct.

> 
> [...]
> 
> > diff --git a/drivers/infiniband/hw/cxgb4/user.h b/drivers/infiniband/hw/cxgb4/user.h
> > index 32b754c..11ccd27 100644
> > --- a/drivers/infiniband/hw/cxgb4/user.h
> > +++ b/drivers/infiniband/hw/cxgb4/user.h
> > @@ -70,4 +70,9 @@ struct c4iw_create_qp_resp {
> >  	__u32 qid_mask;
> >  	__u32 flags;
> >  };
> > +
> > +struct c4iw_alloc_ucontext_resp {
> > +	__u64 status_page_key;
> > +	__u32 status_page_size;
> > +};
> 
> If this is going to be part of the ABI, mind add an explicit padding to
> align the structure on 64bits.
> 

Sounds good.  Can you provide patches for these?


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
