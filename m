From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch -next] mlx5_core: warn if no space left in alloc_4k()
Date: Mon, 4 Nov 2013 02:16:12 +0300
Message-ID: <20131103231612.GS20521@mwanda>
References: <20131101102044.GB29795@longonot.mountain>
 <20131103070326.GA3051@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eli Cohen <eli@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17226 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729Ab3KCXQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 18:16:31 -0500
Content-Disposition: inline
In-Reply-To: <20131103070326.GA3051@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 03, 2013 at 09:03:27AM +0200, Eli Cohen wrote:
> On Fri, Nov 01, 2013 at 01:20:44PM +0300, Dan Carpenter wrote:
> > The warning was unreachable.  In the original code, it would print the
> > line number and the function but I have added an error message.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > ---
> > I haven't tested this, hopefully the warning is not annoying.
> > 
> > diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> > index ba816c2..cb86265 100644
> > --- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> > +++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> > @@ -193,8 +193,8 @@ static int alloc_4k(struct mlx5_core_dev *dev, u64 *addr)
> >  	unsigned n;
> >  
> >  	if (list_empty(&dev->priv.free_list)) {
> > +		mlx5_core_warn(dev, "no available space\n");
> >  		return -ENOMEM;
> > -		mlx5_core_warn(dev, "\n");
> >  	}
> 
> What we really need to do here is silently return -ENOMEM. The list
> can be found empty on a regular basis so we don't want to flood dmesg
> with annoying messages. The statement was probably left there from a
> previous debug cycle.

Ah, ok.  Thanks for the review.  I will remove the message.

regards,
dan carpenter
