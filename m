From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: Re: [PATCH] net: wan: Use dma_pool_zalloc
Date: Fri, 16 Dec 2016 11:33:17 +0530
Message-ID: <CAFqt6zaPWuc+gZTMqk-gh8weZvAjvVwm0kyDT5ub=iah=y9skA@mail.gmail.com>
References: <20161203091447.GA5231@jordon-HP-15-Notebook-PC>
 <m3wpf9l0fc.fsf@t19.piap.pl> <CAFqt6zZoEfE8Us+vx_VuFyqK-zth9ac=aZXo2MKD-4RUBqm5GQ@mail.gmail.com>
 <CAFqt6zaHJ_YP-inLm8_XRDrX8FtcU86NqYG=+DRn9-Y3zR4cyg@mail.gmail.com> <1481820487.29291.66.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Krzysztof_Ha=C5=82asa?= <khalasa@piap.pl>,
        netdev@vger.kernel.org, Rameshwar Sahu <sahu.rameshwar73@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36012 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751321AbcLPG3d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 01:29:33 -0500
Received: by mail-io0-f196.google.com with SMTP id b194so10880307ioa.3
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 22:29:33 -0800 (PST)
In-Reply-To: <1481820487.29291.66.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 10:18 PM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2016-12-15 at 10:41 +0530, Souptick Joarder wrote:
>> On Mon, Dec 12, 2016 at 10:12 AM, Souptick Joarder <jrdr.linux@gmail.com=
> wrote:
>> > On Fri, Dec 9, 2016 at 6:33 PM, Krzysztof Ha=C5=82asa <khalasa@piap.pl=
> wrote:
>> > > Souptick Joarder <jrdr.linux@gmail.com> writes:
>> > >
>> > > > We should use dma_pool_zalloc instead of dma_pool_alloc/memset
> []
>> > > > diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx=
_hss.c
> []
>> > > > @@ -976,10 +976,9 @@ static int init_hdlc_queues(struct port *port=
)
>> > > >                       return -ENOMEM;
>> > > >       }
>> > > >
>> > > > -     if (!(port->desc_tab =3D dma_pool_alloc(dma_pool, GFP_KERNEL=
,
>> > > > -                                           &port->desc_tab_phys))=
)
>> > > > +     if (!(port->desc_tab =3D dma_pool_zalloc(dma_pool, GFP_KERNE=
L,
>> > > > +                                            &port->desc_tab_phys)=
))
>> > > >               return -ENOMEM;
>> > > > -     memset(port->desc_tab, 0, POOL_ALLOC_SIZE);
>> > > >       memset(port->rx_buff_tab, 0, sizeof(port->rx_buff_tab)); /* =
tables */
>> > > >       memset(port->tx_buff_tab, 0, sizeof(port->tx_buff_tab));
>> > >
>> > > This look fine, feel free to send it to the netdev mailing list for
>> > > inclusion.
>> >
>> > Including netdev mailing list based as requested.
>> > > Acked-by: Krzysztof Halasa <khalasa@piap.pl>
> []
>> Any comment on this patch ?
>
> Shouldn't the one in drivers/net/ethernet/xscale/ixp4xx_eth.c
> also be changed?

Yes, you are right.   Do you want me to include it in same patch?

Regards
Souptick
