From: <Nisar.Sayed@microchip.com>
Subject: RE: [PATCH v2 net 1/3] lan78xx: Fix for eeprom read/write when
 device auto suspend
Date: Tue, 12 Sep 2017 13:01:17 +0000
Message-ID: <CE371C1263339941885964188A0225FA336142@CHN-SV-EXMX03.mchp-main.com>
References: <CE371C1263339941885964188A0225FA335C84@CHN-SV-EXMX03.mchp-main.com>
 <20170911202428.GB5983@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>,
        <netdev@vger.kernel.org>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:55396 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751843AbdILNCF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 09:02:05 -0400
In-Reply-To: <20170911202428.GB5983@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > From: Nisar Sayed <Nisar.Sayed@microchip.com>
> >
> > Fix for eeprom read/write when device auto suspend
> >
> > Fixes: 55d7de9de6c3 ("Microchip's LAN7800 family USB 2/3 to
> > 10/100/1000 Ethernet device driver")
> > Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
> > ---
> >  drivers/net/usb/lan78xx.c | 22 ++++++++++++++++++----
> >  1 file changed, 18 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> > index b99a7fb..baf91c7 100644
> > --- a/drivers/net/usb/lan78xx.c
> > +++ b/drivers/net/usb/lan78xx.c
> > @@ -1265,30 +1265,44 @@ static int lan78xx_ethtool_get_eeprom(struct
> net_device *netdev,
> >  				      struct ethtool_eeprom *ee, u8 *data)  {
> >  	struct lan78xx_net *dev = netdev_priv(netdev);
> > +	int ret = -EINVAL;
> > +
> > +	if (usb_autopm_get_interface(dev->intf) < 0)
> > +		return ret;
> 
> Hi Nisar
> 
> It is better to do
> 
>    ret = usb_autopm_get_interface(dev->intf;
>    if (ret)
>         return ret;
> 
> i.e. use the error code usb_autopm_get_interface() gives you.
> 
> >  	ee->magic = LAN78XX_EEPROM_MAGIC;
> >
> > -	return lan78xx_read_raw_eeprom(dev, ee->offset, ee->len, data);
> > +	ret = lan78xx_read_raw_eeprom(dev, ee->offset, ee->len, data);
> > +
> > +	usb_autopm_put_interface(dev->intf);
> > +
> > +	return ret;
> >  }
> >
> >  static int lan78xx_ethtool_set_eeprom(struct net_device *netdev,
> >  				      struct ethtool_eeprom *ee, u8 *data)  {
> >  	struct lan78xx_net *dev = netdev_priv(netdev);
> > +	int ret = -EINVAL;
> > +
> > +	if (usb_autopm_get_interface(dev->intf) < 0)
> > +		return ret;
> 
> Same here.
> 
>      Andrew

Thanks Andrew, will update it.

- Nisar
