From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: Re: [PATCH] phylib: phy_ethtool_{sset,gset} -- check phydev for NULL
Date: Fri, 11 May 2007 17:49:19 +0400
Message-ID: <8496f91a0705110649w2f42c26fi65db0d92fb8bdfd8@mail.gmail.com>
References: <8496f91a0705101029g794ee4a7t1c6a34ad13444c49@mail.gmail.com>
	 <20070510105613.f564e083.randy.dunlap@oracle.com>
	 <46436215.7030503@garzik.org>
	 <8496f91a0705110358v2e6d9b7el19856eadd55ac596@mail.gmail.com>
	 <0DF2860D-0764-4AD1-B8B9-205827FF28E3@kernel.crashing.org>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>,
	"Randy Dunlap" <randy.dunlap@oracle.com>, netdev@vger.kernel.org
To: "Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.224]:50787 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754835AbXEKNtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 09:49:20 -0400
Received: by nz-out-0506.google.com with SMTP id o1so997311nzf
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 06:49:19 -0700 (PDT)
In-Reply-To: <0DF2860D-0764-4AD1-B8B9-205827FF28E3@kernel.crashing.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/5/11, Kumar Gala <galak@kernel.crashing.org>:
>
> On May 11, 2007, at 5:58 AM, Matvejchikov Ilya wrote:
>
> > Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
> > ---
> >
> > diff -purN linux-2.6.21-clean/drivers/net/phy/phy.c
> > linux-2.6.21/drivers/net/phy/phy.c
> > --- linux-2.6.21-clean/drivers/net/phy/phy.c  2007-04-26
> > 07:08:32.000000000 +0400
> > +++ linux-2.6.21/drivers/net/phy/phy.c        2007-05-04
> > 08:22:01.000000000 +0400
> > @@ -245,6 +245,9 @@ EXPORT_SYMBOL(phy_sanitize_settings);
> >  */
> > int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd
> > *cmd)
> > {
> > +     if (unlikely(!phydev))
> > +             return -EINVAL;
>
> Should this be -ENODEV?

If we get the ENODEV error, we are suppose that there is no device at
all. PHY device may not be connected to the NET device. But if it
exists we can't say that there is NODEV...

I think it should be -EINVAL.

> > +
> >       if (cmd->phy_address != phydev->addr)
> >               return -EINVAL;
> >
> > @@ -289,6 +292,9 @@ EXPORT_SYMBOL(phy_ethtool_sset);
> >
> > int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd
> > *cmd)
> > {
> > +     if (unlikely(!phydev))
> > +             return -EINVAL;
>
> same question.

The same answer :)

> > +
> >       cmd->supported = phydev->supported;
> >
> >       cmd->advertising = phydev->advertising;
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
