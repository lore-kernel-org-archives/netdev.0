From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Net-ethtool : Allow ethtool to set interface in
 loopback mode.
Date: Tue, 30 Nov 2010 19:15:07 +0000
Message-ID: <1291144507.21077.56.camel@bwh-desktop>
References: <AANLkTikVaVv4fkLom+NSQgOUzCd2i3mbHkBNQ6PD4d9Y@mail.gmail.com>
	 <1291129305.21077.9.camel@bwh-desktop>
	 <AANLkTikM4=yOu9L7h0FZUkmMNG-LVdGsdSLOLJmw2+UW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	laurent chavey <chavey@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14507 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab0K3TPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 14:15:10 -0500
In-Reply-To: <AANLkTikM4=yOu9L7h0FZUkmMNG-LVdGsdSLOLJmw2+UW@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-30 at 11:05 -0800, Mahesh Bandewar wrote:
> On Tue, Nov 30, 2010 at 7:01 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
[...]
> > > diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> > > index 6628a50..7523d45 100644
> > > --- a/include/linux/ethtool.h
> > > +++ b/include/linux/ethtool.h
> > > @@ -678,6 +678,8 @@ struct ethtool_ops {
> > >                                   struct ethtool_rxfh_indir *);
> > >         int     (*set_rxfh_indir)(struct net_device *,
> > >                                   const struct ethtool_rxfh_indir *);
> > > +       int     (*get_loopback)(struct net_device *, u32 *);
> > > +       int     (*set_loopback)(struct net_device *, u32);
> > >  };
> > >  #endif /* __KERNEL__ */
> > >
> > > @@ -741,6 +743,8 @@ struct ethtool_ops {
> > >  #define ETHTOOL_GSSET_INFO     0x00000037 /* Get string set info */
> > >  #define ETHTOOL_GRXFHINDIR     0x00000038 /* Get RX flow hash indir'n table */
> > >  #define ETHTOOL_SRXFHINDIR     0x00000039 /* Set RX flow hash indir'n table */
> > > +#define ETHTOOL_SLOOPBACK      0x0000003a /* Enable / Disable Loopback */
> > [...]
> >
> > Where should loopback be done, when enabled?  As near as possible to the
> > host, so it only covers the DMA engines, or as far away as possible, so
> > it covers most of the MAC/PHY hardware?
> >
> Putting it very close to the HW would stress the maximum soft path and
> would make it
> beneficial to more people / developers. I understand that capabilities
> offered by different
> NIC vendors vary so it's little difficult to draw the line as to where
> it  should be done.

Of course, that's why I suggest 'as near/far as possible' rather than
trying to specify the exact point at which loopback would be enabled.

> So
> if the theme to "maximize the soft path" is maintained, we can leave
> it to the individual
> driver(s) to maximize the value in offering.

I think this should be specified, otherwise measurements on different
types of NIC will not be comparable.  The ethtool API suffers greatly
from losse specification and resulting inconsistency between drivers.
So please add the comment that loopback should be enabled as near to the
host as possible.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

