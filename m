From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 net-next] net: fec: Ensure clocks are enabled while
 using mdio bus
Date: Sat, 20 Jun 2015 19:58:17 +0200
Message-ID: <20150620175817.GA9863@lunn.ch>
References: <1434816914-9816-1-git-send-email-andrew@lunn.ch>
 <CAOMZO5Bb2i2Xr2-+6pNSy5WHxh1FK3utB3-VqS6X-_OK=+t82g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Duan Andy <fugang.duan@freescale.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60021 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754655AbbFTSEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 14:04:11 -0400
Content-Disposition: inline
In-Reply-To: <CAOMZO5Bb2i2Xr2-+6pNSy5WHxh1FK3utB3-VqS6X-_OK=+t82g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 20, 2015 at 02:47:20PM -0300, Fabio Estevam wrote:
> On Sat, Jun 20, 2015 at 1:15 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> 
> > @@ -1764,6 +1765,11 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
> >  {
> >         struct fec_enet_private *fep = bus->priv;
> >         unsigned long time_left;
> > +       int ret;
> > +
> > +       ret = clk_prepare_enable(fep->clk_ipg);
> > +       if (ret)
> > +               return 0xffff;
> 
> Why don`t you return ret instead?

ret would also work.

v3 to follow soon.

   Andrew
