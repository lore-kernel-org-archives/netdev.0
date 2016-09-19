From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCH 2/2] iw_cxgb4: add fast-path for small REG_MR operations
Date: Sun, 18 Sep 2016 19:40:29 -0500
Message-ID: <0bd501d2120e$6bf5aaf0$43e100d0$@opengridcomputing.com>
References: <cover.1474037695.git.swise@opengridcomputing.com> <3153440ff068cc56a517af2ba6be2b0de0f4dd99.1474037695.git.swise@opengridcomputing.com> <20160918142242.GJ2923@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "'Leon Romanovsky'" <leonro-2ukJVAZIZ/Y@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160918142242.GJ2923-2ukJVAZIZ/Y@public.gmane.org>
Content-Language: en-us
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On Fri, Sep 16, 2016 at 07:54:52AM -0700, Steve Wise wrote:
> > When processing a REG_MR work request, if fw supports the
> > FW_RI_NSMR_TPTE_WR work request, and if the page list for this
> > registration is <= 2 pages, and the current state of the mr is INVALID,
> > then use FW_RI_NSMR_TPTE_WR to pass down a fully populated TPTE for
> FW
> > to write.  This avoids FW having to do an async read of the TPTE
blocking
> > the SQ until the read completes.
> >
> > To know if the current MR state is INVALID or not, iw_cxgb4 must track
the
> > state of each fastreg MR.  The c4iw_mr struct state is updated as REG_MR
> > and LOCAL_INV WRs are posted and completed, when a reg_mr is
> destroyed,
> > and when RECV completions are processed that include a local
invalidation.
> >
> > This optimization increases small IO IOPS for both iSER and NVMF.
> >
> > Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
> > ---
> 
> <...>
> 
> > +			      struct ib_reg_wr *wr, struct c4iw_mr *mhp,
> > +			      u8 *len16)
> > +{
> > +	__be64 *p = (__be64 *)fr->pbl;
> > +
> > +	fr->r2 = cpu_to_be32(0);
> 
> Is there any difference between the line above and "fr->r2 = 0"?

It makes sparse happy, IIRC...



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
