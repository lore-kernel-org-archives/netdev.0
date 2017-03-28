From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net-next v2 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Tue, 28 Mar 2017 14:05:13 +0800
Message-ID: <1490681113.14184.39.camel@mtkswgap22>
References: <1490088910-19405-1-git-send-email-sean.wang@mediatek.com>
         <1490088910-19405-6-git-send-email-sean.wang@mediatek.com>
         <20170324140215.GG28518@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <f.fainelli@gmail.com>, <vivien.didelot@savoirfairelinux.com>,
        <matthias.bgg@gmail.com>, <robh+dt@kernel.org>,
        <mark.rutland@arm.com>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <davem@davemloft.net>,
        <Landen.Chao@mediatek.com>, <keyhaede@gmail.com>,
        <objelf@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170324140215.GG28518@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Andrew,

Add comment as below inline


On Fri, 2017-03-24 at 15:02 +0100, Andrew Lunn wrote:
> Hi Sean
> 
> > +	regmap = devm_regmap_init(ds->dev, NULL, priv,
> > +				  &mt7530_regmap_config);
> > +	if (IS_ERR(regmap))
> > +		dev_warn(priv->dev, "phy regmap initialization failed");
> > +
> 
> Shouldn't this be a fatal error? If you keep going when there is an
> error, what happens when you actually try to use the regmap?
> 

Initial thought is that it is just for debugging purpose so if it fails,
it should break any functionality of switch and only have implication as
a warning message. 

Anyway, i will remove it in the next one since it seems better being
kept in private place as you suggested in the previous mail.  

> > +	phy_mode = of_get_phy_mode(ds->ports[ds->dst->cpu_port].dn);
> > +	if (phy_mode < 0) {
> > +		dev_err(priv->dev, "Can't find phy-mode for master device\n");
> > +		return phy_mode;
> > +	}
> > +	dev_info(priv->dev, "phy-mode for master device = %x\n", phy_mode);
> 
> dev_dbg? 
> 

Sorry. i forgot turned it into dev_dbg

> > +
> > +	id = mt7530_read(priv, MT7530_CREV);
> > +	id >>= CHIP_NAME_SHIFT;
> > +	if (id != MT7530_ID)
> > +		return -ENODEV;
> 
> It might be helpful to say what ID has been found, if it is not the
> supported ID.


I will fix it up to make users know what was going on 

thanks for taking your time on those reviewing again!


> 	Andrew
