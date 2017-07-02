From: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Subject: Re: [PATCH] net: axienet: add of_phy_connect call for
 XAE_PHY_TYPE_MII case
Date: Sun, 2 Jul 2017 12:19:14 +0200
Message-ID: <20170702101914.5nk27r2h754qzthe@collins.gmr.ssr.upm.es>
References: <20170630092541.27234-1-alvaro.gamez@hazent.com>
 <425aed84-a1b6-b8da-5989-3bef5a03ead4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?iso-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <425aed84-a1b6-b8da-5989-3bef5a03ead4@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2017 at 10:30:38AM -0700, Florian Fainelli wrote:
> On 06/30/2017 02:25 AM, Alvaro Gamez Machado wrote:
> >  	if (lp->phy_node) {
> > -		if (lp->phy_type == XAE_PHY_TYPE_GMII) {
> > +		if (lp->phy_type == XAE_PHY_TYPE_MII) {
> > +			phydev = of_phy_connect(lp->ndev, lp->phy_node,
> > +						axienet_adjust_link, 0,
> > +						PHY_INTERFACE_MODE_MII);
> > +		} else if (lp->phy_type == XAE_PHY_TYPE_GMII) {
> >  			phydev = of_phy_connect(lp->ndev, lp->phy_node,
> >  						axienet_adjust_link, 0,
> >  						PHY_INTERFACE_MODE_GMII);
> 
> Seems like this could be simplified even further if the values of
> lp->phy_type directly mapped to those of phy_interface_t.

Sadly, that's not the case. PHY_INTERFACE_MODE_* belong to a enum of twenty
different values, of which only _MII and _GMII overlap with XAW_PHY_*
values, but XAE_PHY_TYPE_RGMII_2_0 doesn't match
PHY_INTERFACE_MODE_RGMII_ID.

Regards
-- 
Alvaro G. M.
