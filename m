From: Albert ARIBAUD <albert.aribaud@3adev.fr>
Subject: Re: [PATCH] net: trivial: fix fsl fec_main mdio write return value
Date: Mon, 26 Sep 2016 23:10:41 +0200
Message-ID: <20160926231041.41091069.albert.aribaud@3adev.fr>
References: <20160926191140.12107-1-albert.aribaud@3adev.fr>
        <CAOMZO5BikGA9e6goMs0wqNVHvWW9Mf3SpykA=DWfD4Q2gBbkag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Kosina <trivial@kernel.org>,
        Fugang Duan <fugang.duan@nxp.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:47496 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750977AbcIZVKw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 17:10:52 -0400
In-Reply-To: <CAOMZO5BikGA9e6goMs0wqNVHvWW9Mf3SpykA=DWfD4Q2gBbkag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fabio,

You are correct -- I'd rebased my patch as part of a series, and I did
not notice that the fix was already there. Apologies and thanks for
pointing it out.

Le Mon, 26 Sep 2016 18:00:32 -0300, Fabio Estevam <festevam@gmail.com>
a écrit :

> Hi Albert,
> 
> On Mon, Sep 26, 2016 at 4:11 PM, Albert ARIBAUD (3ADEV)
> <albert.aribaud@3adev.fr> wrote:
> > If the MDIO enf-of-transfer wait loop does not time out,
> > 0 should be returned to the caller through ret, but ret
> > was not reset to 0 after receiving the return value of
> > pm_runtime_get_sync(). Reset ret when no time out occurred.Is this really needed?  
> 
> Commit 42ea4457 ("net: fec: normalize return value of
> pm_runtime_get_sync() in MDIO write") does the following:
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 91925e3..6cc3340 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1816,11 +1816,13 @@ static int fec_enet_mdio_write(struct mii_bus
> *bus, int mii_id, int regnum,
>         struct fec_enet_private *fep = bus->priv;
>         struct device *dev = &fep->pdev->dev;
>         unsigned long time_left;
> -       int ret = 0;
> +       int ret;
> 
>         ret = pm_runtime_get_sync(dev);
>         if (ret < 0)
>                 return ret;
> +       else
> +               ret = 0;
> 
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c index 01f7e81..0413c05
> > 100644 --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -1818,6 +1818,8 @@ static int fec_enet_mdio_write(struct mii_bus
> > *bus, int mii_id, int regnum, netdev_err(fep->netdev, "MDIO write
> > timeout\n"); ret  = -ETIMEDOUT;
> >         }
> > +       else
> > +               ret = 0;  
> 
> , so is this really needed? ret should be 0 at this point.



Cordialement,
Albert ARIBAUD
3ADEV
