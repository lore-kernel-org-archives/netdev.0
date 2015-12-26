From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 6/7] drivers: net: cpsw: fix error return code
Date: Sat, 26 Dec 2015 21:07:27 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1512262101430.2070@localhost6.localdomain6>
References: <1451143726-28195-1-git-send-email-Julia.Lawall@lip6.fr> <1451143726-28195-7-git-send-email-Julia.Lawall@lip6.fr> <567ED019.3000407@cogentembedded.com> <alpine.DEB.2.02.1512261838330.2064@localhost6.localdomain6> <567ED36A.9000701@cogentembedded.com>
 <567EEFC2.4080800@cogentembedded.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <567EEFC2.4080800@cogentembedded.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 26 Dec 2015, Sergei Shtylyov wrote:

> Hello.
> 
> On 12/26/2015 08:50 PM, Sergei Shtylyov wrote:
> 
> > > > > diff --git a/drivers/net/ethernet/ti/cpsw.c
> > > > > b/drivers/net/ethernet/ti/cpsw.c
> > > > > index 3409e80..6a76992 100644
> > > > > --- a/drivers/net/ethernet/ti/cpsw.c
> > > > > +++ b/drivers/net/ethernet/ti/cpsw.c
> > > > > @@ -2448,8 +2448,10 @@ static int cpsw_probe(struct platform_device
> > > > > *pdev)
> > > > > 
> > > > >        /* RX IRQ */
> > > > >        irq = platform_get_irq(pdev, 1);
> > > > > -    if (irq < 0)
> > > > > +    if (irq < 0) {
> > > > > +        ret = -ENOENT;
> > > > 
> > > >     Why not just propagate an error returned by that function?
> > > 
> > > OK, I did what was done a few lines before in the same function:
> > > 
> > >          ndev->irq = platform_get_irq(pdev, 1);
> > >          if (ndev->irq < 0) {
> > >         dev_err(priv->dev, "error getting irq resource\n");
> > >                  ret = -ENOENT;
> > >                  goto clean_ale_ret;
> > >          }
> > > 
> > > Maybe they should all be changed?
> > 
> >     Yeah, I'd vote for it. I'm seeing no sense in overriding an actual
> > error.
> 
>    Hm, I decided to check drivers/base/dd.c and I think I maybe know the
> reason now: -ENXIO, usually returned by platform_get_irq(), is silently
> "swallowed" by really_probe(); to be precise, -ENODEV and -ENXIO are only
> reported with pr_debug(), while -ENOENT causes printk(KERN_WARNING, ...)...

Sorry, I'm confused...  What should it be?  v1 or v2?  Here are the counts 
of the different constants returned on failure of platform_get_irq:

ENODEV: 84
ENXIO: 67
EINVAL: 61
ENOENT: 29
EBUSY: 11
EIO: 2
EPROBE_DEFER: 1

julia
