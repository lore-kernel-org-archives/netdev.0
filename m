From: Varun Prakash <varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/4] cxgb4/iw_cxgb4/cxgb4i: remove duplicate
 definitions
Date: Wed, 15 Apr 2015 18:34:27 +0530
Message-ID: <20150415130425.GA5317@chelsio.com>
References: <cover.1428930614.git.varun@chelsio.com>
 <6358f849b5a1a3727879f4f2f5c855e3a5b95ab4.1428930614.git.varun@chelsio.com>
 <20150413163808.GA17521@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	<leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	<kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <praveenm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150413163808.GA17521-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 13, 2015 at 10:38:08AM -0600, Jason Gunthorpe wrote:
> On Mon, Apr 13, 2015 at 07:34:23PM +0530, Varun Prakash wrote:
> > define struct ulptx_idata in common header file t4_msg.h
> > to remove duplicate definitions.
> 
> The Infiniband side of this patch looks OK.
> 
> Reviewed-By: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
> 
> Just some random thoughts on the other patches:
>  - Try and use 'if (IS_ENABLED(CONFIG_XX))' over #ifdef 
>    to improve compile test coverage. This would drop a fair number
>    of ifdefs.

FCoE specific structures and functions are defined only if 
CONFIG_CHELSIO_T4_FCOE is enabled.

#ifdef CONFIG_CHELSIO_T4_FCOE
void cxgb_fcoe_init_ddp(struct adapter *adap)
{
	...
}
#endif

If CONFIG_CHELSIO_T4_FCOE is disabled then following code will
result in build error "implicit declaration of function cxgb_fcoe_init_ddp"

if (IS_ENABLED(CONFIG_CHELSIO_T4_FCOE))
	cxgb_fcoe_init_ddp(adap);

>  - Some of the commit message are short, or non existant (ie #4)
>  - Generally, no need for 'static inline' in a .c file, the compiler knows
>    what to do.
> 
> Regards,
> Jason
>
Thanks 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
