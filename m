From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] net: make ndev->irq signed for error handling
Date: Thu, 7 Nov 2013 04:22:49 -0800 (PST)
Message-ID: <20131107122249.GN20521@mwanda>
References: <20131107074849.GF21844@elgon.mountain> <527B842E.2060909@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <527B842E.2060909@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 07, 2013 at 05:44:38PM +0530, Mugunthan V N wrote:
> On Thursday 07 November 2013 01:18 PM, Dan Carpenter wrote:
> > There is a bug in cpsw_probe() where we do:
> >
> > 	ndev->irq = platform_get_irq(pdev, 0);
> > 	if (ndev->irq < 0) {
> >
> > The problem is that "ndev->irq" is unsigned so the error handling
> > doesn't work.  I have changed it to a regular int.
> >
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ndev->irq is never used any where in the driver, I think its better to
> remove this part of code from probe. If every one is ok, I can send a
> patch to remove the code.

It seems like cpsw_ndo_poll_controller() uses it.

regards,
dan carpenter
