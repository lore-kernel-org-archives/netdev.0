From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH] net-bnx2x: Force link UP when the interface is in
 LOOPBACK mode
Date: Wed, 30 Jan 2013 08:52:53 -0800
Message-ID: <CAF2d9jjTWPYMV22Z1ZgXa7ynXfkzWoRryWGvj87mEjDk6rkUjw@mail.gmail.com>
References: <1359510715-12099-1-git-send-email-maheshb@google.com> <1359541491.26518.2.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yaniv Rosner <yanivr@broadcom.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:36147 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737Ab3A3QxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 11:53:13 -0500
Received: by mail-da0-f42.google.com with SMTP id z17so855889dal.1
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 08:53:13 -0800 (PST)
In-Reply-To: <1359541491.26518.2.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2013 at 2:24 AM, Eilon Greenstein <eilong@broadcom.com> wrote:
>
> On Tue, 2013-01-29 at 17:51 -0800, Mahesh Bandewar wrote:
> > When the interface does not have carrier but when it's put into
> > loopback mode (for tests), it does not make sense to not have
> > the carrier. So force it!
> >
>
> Mahesh,
>
> What is the motivation for this change? During the test, the device is
> not really functional and cannot receive traffic to the loopback, so why
> would you like to indicate internally that the link is up?
>
The device is capable of NETIF_F_LOOPBACK so when enabled, it does not
receive traffic from the wire but from the host-side it is functional.
Not having carrier is a problem in that scenario.

> > Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> > ---
> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> >
> > diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> > index 859df751345e..91af55586bbc 100644
> > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> > @@ -4748,6 +4748,11 @@ void bnx2x_link_status_update(struct link_params *params,
> >       vars->link_status = REG_RD(bp, params->shmem_base +
> >                                  offsetof(struct shmem_region,
> >                                           port_mb[port].link_status));
> > +
> > +     /* Force link UP in loopback mode */
> > +     if (bp->link_params.loopback_mode != LOOPBACK_NONE)
>
> The LOOPBACK_EXT requires an external loopback so we should not just
> force link up indication for that kind of loopback.
>
Yes, that's true! Let me correct this. I'll add a condition to check
that it's not EXT mode before forcing the link.
> > +             vars->link_status |= LINK_STATUS_LINK_UP;
> > +
> >       if (bnx2x_eee_has_cap(params))
> >               vars->eee_status = REG_RD(bp, params->shmem2_base +
> >                                         offsetof(struct shmem2_region,
>
> Thanks,
> Eilon
>
>
