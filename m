From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH net 2/2] sh_eth: Fix ethtool operation crash when net
 device is down
Date: Mon, 19 Jan 2015 10:41:25 +0000
Message-ID: <1421664085.1222.200.camel@xylophone.i.decadent.org.uk>
References: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk>
	 <1421430685.1222.192.camel@xylophone.i.decadent.org.uk>
	 <CAGVrzcbj2JANTECtxgDUrb7c_20nyoW4n5ARndHGKYuQu-0kQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ct178-internal@lists.codethink.co.uk,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@lists.codethink.co.uk>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:44401 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722AbbASKl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 05:41:29 -0500
In-Reply-To: <CAGVrzcbj2JANTECtxgDUrb7c_20nyoW4n5ARndHGKYuQu-0kQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-16 at 10:45 -0800, Florian Fainelli wrote:
> 2015-01-16 9:51 GMT-08:00 Ben Hutchings <ben.hutchings@codethink.co.uk>:
[...]
> > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> > @@ -1827,6 +1827,9 @@ static int sh_eth_get_settings(struct net_device *ndev,
> >         unsigned long flags;
> >         int ret;
> >
> > +       if (!mdp->phydev)
> > +               return -ENODEV;
> 
> Since the PHY is disconnected, would not checking for netif_running()
> make sense here, unless there is a good reason to still allow
> phy_ethtool_gset() to be called?
[...]

I think those two conditions will be equivalent, won't they?  Writing
the condition like this will also work if the driver later supports
PHY-less configurations.

Ben.
