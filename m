From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH 1/2] mlx4: remove unnecessary pci_set_drvdata()
Date: Tue, 15 Aug 2017 11:21:49 -0600
Message-ID: <20170815172149.GC15171@obsidianresearch.com>
References: <1502778786-14738-1-git-send-email-yanjun.zhu@oracle.com>
 <20170815071336.GL24282@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhu Yanjun <yanjun.zhu@oracle.com>, saeedm@mellanox.com,
        matanb@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, yuval.shaia@oracle.com
To: Leon Romanovsky <leonro@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:45135 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752971AbdHORVx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 13:21:53 -0400
Content-Disposition: inline
In-Reply-To: <20170815071336.GL24282@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 10:13:36AM +0300, Leon Romanovsky wrote:
> On Tue, Aug 15, 2017 at 02:33:05AM -0400, Zhu Yanjun wrote:
> > The driver core clears the driver data to NULL after device_release
> > or on probe failure. Thus, it is not necessary to manually clear the
> > device driver data to NULL.
> >
> 
> It makes sense and I'm pretty sure that you are right, but I'm failing
> to find the function in device core which sets it to NULL. Can you help
> me and present the actual call stack to that code place?

http://elixir.free-electrons.com/linux/v4.13-rc1/source/drivers/base/dd.c#L840

The call to the remove callback is on line 833.

This is done after dropping devres, so you could allocate the drv data
inside a devm object and everything would unwind correctly.

In this case, the kfree is explicit, so I would advocate for still putting
the null near the kfree to minimize the time where a free'd pointer is
present - eg incase a devm callback or some other bug accidently
touches it.

Jason
