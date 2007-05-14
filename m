From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: Re: [PATCH] phylib: phy_ethtool_{sset,gset} -- check phydev for NULL
Date: Mon, 14 May 2007 23:32:40 +0400
Message-ID: <8496f91a0705141232y6f8e7929va350702bd5ea0df1@mail.gmail.com>
References: <8496f91a0705101029g794ee4a7t1c6a34ad13444c49@mail.gmail.com>
	 <20070510105613.f564e083.randy.dunlap@oracle.com>
	 <46436215.7030503@garzik.org>
	 <8496f91a0705110358v2e6d9b7el19856eadd55ac596@mail.gmail.com>
	 <0DF2860D-0764-4AD1-B8B9-205827FF28E3@kernel.crashing.org>
	 <8496f91a0705110649w2f42c26fi65db0d92fb8bdfd8@mail.gmail.com>
	 <83E62581-EB88-4FC1-9DF9-8F725577F825@kernel.crashing.org>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>,
	"Randy Dunlap" <randy.dunlap@oracle.com>, netdev@vger.kernel.org
To: "Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:29018 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754611AbXENTcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 15:32:41 -0400
Received: by py-out-1112.google.com with SMTP id a29so1616911pyi
        for <netdev@vger.kernel.org>; Mon, 14 May 2007 12:32:41 -0700 (PDT)
In-Reply-To: <83E62581-EB88-4FC1-9DF9-8F725577F825@kernel.crashing.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/5/11, Kumar Gala <galak@kernel.crashing.org>:
>
> On May 11, 2007, at 8:49 AM, Matvejchikov Ilya wrote:
>
> > 2007/5/11, Kumar Gala <galak@kernel.crashing.org>:
> >>
> >> On May 11, 2007, at 5:58 AM, Matvejchikov Ilya wrote:
> >>
> >> > Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
> >> > ---
> >> >
> >> > diff -purN linux-2.6.21-clean/drivers/net/phy/phy.c
> >> > linux-2.6.21/drivers/net/phy/phy.c
> >> > --- linux-2.6.21-clean/drivers/net/phy/phy.c  2007-04-26
> >> > 07:08:32.000000000 +0400
> >> > +++ linux-2.6.21/drivers/net/phy/phy.c        2007-05-04
> >> > 08:22:01.000000000 +0400
> >> > @@ -245,6 +245,9 @@ EXPORT_SYMBOL(phy_sanitize_settings);
> >> >  */
> >> > int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd
> >> > *cmd)
> >> > {
> >> > +     if (unlikely(!phydev))
> >> > +             return -EINVAL;
> >>
> >> Should this be -ENODEV?
> >
> > If we get the ENODEV error, we are suppose that there is no device at
> > all. PHY device may not be connected to the NET device. But if it
> > exists we can't say that there is NODEV...
> >
> > I think it should be -EINVAL.
>
> Hmm, if the phy isn't connected to the NET device doesn't that mean
> we don't have a PHY device (from the point of view of the netdevice),
> thus NODEV?

It will hardly be understandable for the user...

>
> Whatever we should cleanup the current users of phy_ethtool_sset/
> phy_ethtool_gset.
>

Right you are.

> >> > +
> >> >       if (cmd->phy_address != phydev->addr)
> >> >               return -EINVAL;
> >> >
> >> > @@ -289,6 +292,9 @@ EXPORT_SYMBOL(phy_ethtool_sset);
> >> >
> >> > int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd
> >> > *cmd)
> >> > {
> >> > +     if (unlikely(!phydev))
> >> > +             return -EINVAL;
> >>
> >> same question.
> >
> > The same answer :)
> >
> >> > +
> >> >       cmd->supported = phydev->supported;
> >> >
> >> >       cmd->advertising = phydev->advertising;
> >> > -
> >> > To unsubscribe from this list: send the line "unsubscribe
> >> netdev" in
> >> > the body of a message to majordomo@vger.kernel.org
> >> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >>
>
>
