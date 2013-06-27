From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH net-next v1 1/1] net: fec: Add VLAN receive HW support.
Date: Thu, 27 Jun 2013 11:44:43 +0200
Message-ID: <1372326283.4134.15.camel@weser.hi.pengutronix.de>
References: <Jim Baxter <jim_baxter@mentor.com>
	 <1372204524-27798-1-git-send-email-jim_baxter@mentor.com>
	 <9848F2DB572E5649BA045B288BE08FBE014FE4E1@039-SN2MPN1-023.039d.mgd.msft.net>
	 <51CABDD0.7050606@mentor.com>
	 <9848F2DB572E5649BA045B288BE08FBE01501A58@039-SN2MPN1-023.039d.mgd.msft.net>
	 <51CAD44E.6030308@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Duan Fugang-B38611 <B38611@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	Li Frank-B20596 <B20596@freescale.com>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48086 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915Ab3F0JrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 05:47:11 -0400
In-Reply-To: <51CAD44E.6030308@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, den 26.06.2013, 12:45 +0100 schrieb Jim Baxter:
> On 26/06/13 12:18, Duan Fugang-B38611 wrote:
> > On 06/26/13 18:09, Jim Baxter wrote:
> > 
> >>> In addition,
> >>> 	1.	enet IP support hw VLAN detect such as imx28-fec, imx6q-fec and mvf600-fec, so you can add the "BD_ENET_RX_VLAN " to those platform driver_data.
> >> I have only tested it on the i.MX6, if someone wants to check it on the
> >> imx28 later they can add it to that option.
> > 
> >>> 	2.	Enable the VLAN tag extraction with "NETIF_F_HW_VLAN_CTAG_RX" feature in .ndo_fix_features, which is configured by user.
> >> What do you mean by this, I am only enabling the VLAN code if (ndev->features & NETIF_F_HW_VLAN_CTAG_RX) is set. I am pretty sure this is set by
> > 
> > You can enable the feature like below, which is reasonable.
> > .ndo_fix_features   = fec_enet_fix_features
> > 
> > static netdev_features_t fec_enet_fix_features (struct net_device *dev, 
> >         netdev_features_t features)
> > {
> >         struct fec_enet_private *fep = netdev_priv(dev);
> > 	  const struct platform_device_id *id_entry =
> > 					platform_get_device_id(fep->pdev);
> > 
> > 	  if (id_entry->driver_data & FEC_QUIRK_HAS_VLAN)
> >         	features |= NETIF_F_HW_VLAN_CTAG_RX;
> > 
> > 	  return features;
> > }
> > 
> > 
> > Thank you,
> > Andy
> > 
> > 
> 
> I currently set the features in fec_enet_init() along with setting
> hw_features, is fec_enet_fix_features() a more correct design for driver
> implementation point?
> 
I agree that VLAN tag extraction should not be enabled by default, but
at the users request. But according to the documentation there is no
need to implement the fix_features callback for this to work.

Just only set the hw_features on init, the networking core should take
care of never trying to enable a feature not found in there.

Regards,
Lucas
-- 
Pengutronix e.K.                           | Lucas Stach                 |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-5076 |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
