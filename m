From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: wan: Use dma_pool_zalloc
Date: Thu, 15 Dec 2016 08:48:07 -0800
Message-ID: <1481820487.29291.66.camel@perches.com>
References: <20161203091447.GA5231@jordon-HP-15-Notebook-PC>
         <m3wpf9l0fc.fsf@t19.piap.pl>
         <CAFqt6zZoEfE8Us+vx_VuFyqK-zth9ac=aZXo2MKD-4RUBqm5GQ@mail.gmail.com>
         <CAFqt6zaHJ_YP-inLm8_XRDrX8FtcU86NqYG=+DRn9-Y3zR4cyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Rameshwar Sahu <sahu.rameshwar73@gmail.com>
To: Souptick Joarder <jrdr.linux@gmail.com>,
        Krzysztof =?UTF-8?Q?Ha=C5=82asa?= <khalasa@piap.pl>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0030.hostedemail.com ([216.40.44.30]:41545 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1758047AbcLOQsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 11:48:12 -0500
In-Reply-To: <CAFqt6zaHJ_YP-inLm8_XRDrX8FtcU86NqYG=+DRn9-Y3zR4cyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-15 at 10:41 +0530, Souptick Joarder wrote:
> On Mon, Dec 12, 2016 at 10:12 AM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> > On Fri, Dec 9, 2016 at 6:33 PM, Krzysztof Hałasa <khalasa@piap.pl> wrote:
> > > Souptick Joarder <jrdr.linux@gmail.com> writes:
> > > 
> > > > We should use dma_pool_zalloc instead of dma_pool_alloc/memset
[]
> > > > diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
[]
> > > > @@ -976,10 +976,9 @@ static int init_hdlc_queues(struct port *port)
> > > >                       return -ENOMEM;
> > > >       }
> > > > 
> > > > -     if (!(port->desc_tab = dma_pool_alloc(dma_pool, GFP_KERNEL,
> > > > -                                           &port->desc_tab_phys)))
> > > > +     if (!(port->desc_tab = dma_pool_zalloc(dma_pool, GFP_KERNEL,
> > > > +                                            &port->desc_tab_phys)))
> > > >               return -ENOMEM;
> > > > -     memset(port->desc_tab, 0, POOL_ALLOC_SIZE);
> > > >       memset(port->rx_buff_tab, 0, sizeof(port->rx_buff_tab)); /* tables */
> > > >       memset(port->tx_buff_tab, 0, sizeof(port->tx_buff_tab));
> > > 
> > > This look fine, feel free to send it to the netdev mailing list for
> > > inclusion.
> > 
> > Including netdev mailing list based as requested.
> > > Acked-by: Krzysztof Halasa <khalasa@piap.pl>
[]
> Any comment on this patch ?

Shouldn't the one in drivers/net/ethernet/xscale/ixp4xx_eth.c
also be changed?
