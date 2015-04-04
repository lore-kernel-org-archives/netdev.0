From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: fix filling rtable from OF description
Date: Sat, 4 Apr 2015 23:00:32 +0200
Message-ID: <20150404210032.GB19428@lunn.ch>
References: <1941340.ZSOIoOXLWB@pavel.skitlab.int>
 <20150404163814.GA19428@lunn.ch>
 <43287962.B6uVbMGNYa@kuro.zhome>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Fabian Frederick <fabf@skynet.be>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org
To: Pavel Nakonechny <pavel.nakonechny@skitlab.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37277 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752574AbbDDVEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Apr 2015 17:04:44 -0400
Content-Disposition: inline
In-Reply-To: <43287962.B6uVbMGNYa@kuro.zhome>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 04, 2015 at 08:10:09PM +0300, Pavel Nakonechny wrote:
> Hi Andrew
> 
> ?? ???????????? ???? 4 ???????????? 2015 18:38:14 ???????????????????????? Andrew Lunn ??????????????:
> > There is the code after applying your patch:
> > 
> > static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
> >                                         struct dsa_chip_data *cd,
> >                                         int chip_index, int port_index,
> >                                         struct device_node *link)
> > {
> >         const __be32 *reg;
> >         int link_sw_addr;
> >         struct device_node *parent_sw;
> >         int len;
> > 
> >         parent_sw = of_get_parent(link);
> >         if (!parent_sw)
> >                 return -EINVAL;
> > 
> > link is the phandle to the port in other switch. parent_sw is then the
> > switch property.
> yep
> 
> >         reg = of_get_property(parent_sw, "reg", &len);
> >         if (!reg || (len != sizeof(*reg) * 2))
> >                 return -EINVAL;
> > 
> > So now you get the reg property. This is documented as:
> > 
> > - reg                   : Describes the switch address on the MII bus
> Yes, but read further in the entry example:
> "reg = <16 0>;	/* MDIO address 16, switch 0 in tree */"

Ah!

O.K. Please add a comment. If i read this wrong, it is quite likely
somebody else will also read this wrong.

I think it would also be good to add some text to dsa.txt explaining
this second field in reg.

     Andrew
