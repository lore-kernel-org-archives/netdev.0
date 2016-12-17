From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: wan: Use dma_pool_zalloc
Date: Fri, 16 Dec 2016 16:17:18 -0800
Message-ID: <1481933838.20419.8.camel@perches.com>
References: <20161203091447.GA5231@jordon-HP-15-Notebook-PC>
         <m3wpf9l0fc.fsf@t19.piap.pl>
         <CAFqt6zZoEfE8Us+vx_VuFyqK-zth9ac=aZXo2MKD-4RUBqm5GQ@mail.gmail.com>
         <CAFqt6zaHJ_YP-inLm8_XRDrX8FtcU86NqYG=+DRn9-Y3zR4cyg@mail.gmail.com>
         <1481820487.29291.66.camel@perches.com>
         <CAFqt6zaPWuc+gZTMqk-gh8weZvAjvVwm0kyDT5ub=iah=y9skA@mail.gmail.com>
         <1481868649.29291.85.camel@perches.com>
         <CAFqt6zYasTqZP1GOXJ7u7=L9U8bgM3SnKb-L7yyVVeDTbv+q0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Krzysztof =?UTF-8?Q?Ha=C5=82asa?= <khalasa@piap.pl>,
        netdev@vger.kernel.org, Rameshwar Sahu <sahu.rameshwar73@gmail.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0167.hostedemail.com ([216.40.44.167]:44910 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755376AbcLQARX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 19:17:23 -0500
In-Reply-To: <CAFqt6zYasTqZP1GOXJ7u7=L9U8bgM3SnKb-L7yyVVeDTbv+q0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-16 at 19:25 +0530, Souptick Joarder wrote:
> On Fri, Dec 16, 2016 at 11:40 AM, Joe Perches <joe@perches.com> wrote:
> > On Fri, 2016-12-16 at 11:33 +0530, Souptick Joarder wrote:
> > > On Thu, Dec 15, 2016 at 10:18 PM, Joe Perches <joe@perches.com> wrote:
> > > > On Thu, 2016-12-15 at 10:41 +0530, Souptick Joarder wrote:
> > > > > On Mon, Dec 12, 2016 at 10:12 AM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> > > > > > On Fri, Dec 9, 2016 at 6:33 PM, Krzysztof Hałasa <khalasa@piap.pl> wrote:
> > > > > > > Souptick Joarder <jrdr.linux@gmail.com> writes:
> > > > > > > 
> > > > > > > > We should use dma_pool_zalloc instead of dma_pool_alloc/memset
> > > > 
> > > > []
> > > > > > > > diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
> > > > 
> > > > []
> > > > > > > > @@ -976,10 +976,9 @@ static int init_hdlc_queues(struct port *port)
> > > > > > > >                       return -ENOMEM;
> > > > > > > >       }
> > > > > > > > 
> > > > > > > > -     if (!(port->desc_tab = dma_pool_alloc(dma_pool, GFP_KERNEL,
> > > > > > > > -                                           &port->desc_tab_phys)))
> > > > > > > > +     if (!(port->desc_tab = dma_pool_zalloc(dma_pool, GFP_KERNEL,
> > > > > > > > +                                            &port->desc_tab_phys)))
> > > > > > > >               return -ENOMEM;
> > > > > > > > -     memset(port->desc_tab, 0, POOL_ALLOC_SIZE);
> > > > > > > >       memset(port->rx_buff_tab, 0, sizeof(port->rx_buff_tab)); /* tables */
> > > > > > > >       memset(port->tx_buff_tab, 0, sizeof(port->tx_buff_tab));
> > > > > > > 
> > > > > > > This look fine, feel free to send it to the netdev mailing list for
> > > > > > > inclusion.
> > > > > > 
> > > > > > Including netdev mailing list based as requested.
> > > > > > > Acked-by: Krzysztof Halasa <khalasa@piap.pl>
> > > > 
> > > > []
> > > > > Any comment on this patch ?
> > > > 
> > > > Shouldn't the one in drivers/net/ethernet/xscale/ixp4xx_eth.c
> > > > also be changed?
> > > 
> > > Yes, you are right.   Do you want me to include it in same patch?
> > 
> > Your choice.  I would use a single patch.
> 
> There are few other places where the same change is applicable.
> I am planning to put all those changes in a single patch. It includes
> changes in drivers/net/ethernet/xscale/ixp4xx_eth.c
> 
> You can review this patch separately.

If you are spanning multiple drivers maintained by different
groups, it's probably better to create a patch series, one for
each driver, to allow the various maintainers to apply the
patches to their individually maintained drivers.

Joe
