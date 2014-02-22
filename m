From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH net-next 01/35] bnx2: Use pci_enable_msix_range() instead
 of pci_enable_msix()
Date: Sat, 22 Feb 2014 11:17:22 +0100
Message-ID: <20140222101722.GA28798@dhcp-26-207.brq.redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
 <c8d230441b63d4c30818a55b0e6ca0f376572b87.1392717502.git.agordeev@redhat.com>
 <1393029274.15717.68.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbaBVKP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Feb 2014 05:15:28 -0500
Content-Disposition: inline
In-Reply-To: <1393029274.15717.68.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 22, 2014 at 12:34:34AM +0000, Ben Hutchings wrote:
> > diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> > index cda25ac..ca6b362 100644
> > --- a/drivers/net/ethernet/broadcom/bnx2.c
> > +++ b/drivers/net/ethernet/broadcom/bnx2.c
> > @@ -6206,7 +6206,7 @@ bnx2_free_irq(struct bnx2 *bp)
> >  static void
> >  bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
> >  {
> > -	int i, total_vecs, rc;
> > +	int i, total_vecs;
> >  	struct msix_entry msix_ent[BNX2_MAX_MSIX_VEC];
> >  	struct net_device *dev = bp->dev;
> >  	const int len = sizeof(bp->irq_tbl[0].name);
> > @@ -6229,16 +6229,9 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
> >  #ifdef BCM_CNIC
> >  	total_vecs++;
> >  #endif
> > -	rc = -ENOSPC;
> > -	while (total_vecs >= BNX2_MIN_MSIX_VEC) {
> > -		rc = pci_enable_msix(bp->pdev, msix_ent, total_vecs);
> > -		if (rc <= 0)
> > -			break;
> > -		if (rc > 0)
> > -			total_vecs = rc;
> > -	}
> > -
> > -	if (rc != 0)
> > +	total_vecs = pci_enable_msix_range(bp->pdev, msix_ent,
> > +					   BNX2_MIN_MSIX_VEC, total_vecs);
> > +	if (total_vecs < 0)
> >  		return;
> 
> This would be better without the assignment to total_vecs.

total_vecs is used as a loop limit few lines below.

> Ben.
> 
> >  	msix_vecs = total_vecs;
> 
> -- 
> Ben Hutchings
> I haven't lost my mind; it's backed up on tape somewhere.



-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
