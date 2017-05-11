From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH v1] net/mlx4_core: Use min_t instead of if for consistency
Date: Thu, 11 May 2017 13:27:16 +0300
Message-ID: <20170511102715.GI3011@yuval-lap>
References: <1494492389-15040-1-git-send-email-yuval.shaia@oracle.com>
 <20170511102329.GC3616@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yishaih@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:16597 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755338AbdEKK13 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 06:27:29 -0400
Content-Disposition: inline
In-Reply-To: <20170511102329.GC3616@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 11, 2017 at 01:23:29PM +0300, Leon Romanovsky wrote:
> On Thu, May 11, 2017 at 11:46:29AM +0300, Yuval Shaia wrote:
> > Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>
> > ---
> > v0 -> v1:
> > 	* s/"min_t("/"min_t(int"
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/main.c | 9 ++++-----
> >  1 file changed, 4 insertions(+), 5 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> > index 7032054..7bb377e 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> > @@ -2862,12 +2862,11 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
> >  	int port = 0;
> >
> >  	if (msi_x) {
> > -		int nreq = dev->caps.num_ports * num_online_cpus() + 1;
> > +		int nreq = min_t(int,
> > +				 dev->caps.num_ports * num_online_cpus() + 1,
> > +				 dev->caps.num_eqs - dev->caps.reserved_eqs);
> >
> > -		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
> > -			     nreq);
> > -		if (nreq > MAX_MSIX)
> > -			nreq = MAX_MSIX;
> > +		nreq = min_t(int, nreq, MAX_MSIX);
> 
> You don't need type checking for these variables, they are all int and
> you can use directly min3(..).

Ha ha ha, i can't explain how this macro slipped out from my sight when was
looking for it :).
Hope you can review v2.

> 
> Thanks
> 
> >
> >  		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
> >  		if (!entries)
> > --
> > 2.7.4
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
