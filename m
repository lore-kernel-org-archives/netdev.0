From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: fix poll_controller method so that proper
 structures are passed and all rx queues are checked
Date: Tue, 11 Nov 2008 09:09:10 -0800
Message-ID: <1226423350.23218.9.camel@HP1>
References: <20081111140055.GA30481@hmsreliant.think-freely.org>
 <C27F8246C663564A84BB7AB343977242151F4B18B9@IRVEXCHCCR01.corp.ad.broadcom.com>
 <20081111164634.GB30481@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jgarzik@pobox.com" <jgarzik@pobox.com>,
	"'davem@davemloft.net'" <davem@davemloft.net>
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3724 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752899AbYKKRL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 12:11:57 -0500
In-Reply-To: <20081111164634.GB30481@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-11-11 at 08:46 -0800, Neil Horman wrote:
> On Tue, Nov 11, 2008 at 07:12:13AM -0800, Michael Chan wrote:
> > Neil Horman wrote:
> > > diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> > > index 430d430..9e1f0e3 100644
> > > --- a/drivers/net/bnx2.c
> > > +++ b/drivers/net/bnx2.c
> > > @@ -7203,10 +7203,12 @@ bnx2_change_mtu(struct net_device
> > > *dev, int new_mtu)
> > >  static void
> > >  poll_bnx2(struct net_device *dev)
> > >  {
> > > +     int i;
> > >       struct bnx2 *bp = netdev_priv(dev);
> > >
> > >       disable_irq(bp->pdev->irq);
> > > -     bnx2_interrupt(bp->pdev->irq, dev);
> > > +     for (i = 0; i < bp->irq_nvecs; i++)
> > > +             bnx2_interrupt(bp->pdev->irq, &bp->bnx2_napi[i]);
> > 
> > Neil, thanks for the patch.
> > 
> > We should probably pass bp->irq_tbl[i].vector as 1st parameter
> > for correctness, even though it doesn't really matter in this
> > case since it is not used by bnx2_interrupt().
> > 
> I thought we overwrote pdev->irq with the value from irq_tbl when we registered
> for msi interrupts?
> 

In MSI and INTA mode, we store pdev->irq into irq_tbl[0].vector.  In
MSI-X mode, we'll have multiple vectors in the irq_tbl entries and
pdev->irq is no longer relevant.  So to be correct when we have multiple
vectors, the irq_tbl values should be used.

Thanks.


