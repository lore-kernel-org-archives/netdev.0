From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 2/3] lan78xx: Allow EEPROM write for less than
 MAX_EEPROM_SIZE
Date: Thu, 7 Sep 2017 16:10:48 +0200
Message-ID: <20170907141048.GJ11248@lunn.ch>
References: <CE371C1263339941885964188A0225FA333A7C@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org
To: Nisar.Sayed@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59594 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754005AbdIGOKv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 10:10:51 -0400
Content-Disposition: inline
In-Reply-To: <CE371C1263339941885964188A0225FA333A7C@CHN-SV-EXMX03.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 07, 2017 at 07:11:26AM +0000, Nisar.Sayed@microchip.com wrote:
> From: Nisar Sayed <Nisar.Sayed@microchip.com>
> 
> Allow EEPROM write for less than MAX_EEPROM_SIZE
> 
> Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
> ---
>  drivers/net/usb/lan78xx.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index baf91c7..94ef943 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -1299,6 +1299,10 @@ static int lan78xx_ethtool_set_eeprom(struct net_device *netdev,

static int lan78xx_ethtool_set_eeprom(struct net_device *netdev,
                                      struct ethtool_eeprom *ee, u8 *data)
{
        struct lan78xx_net *dev = netdev_priv(netdev);


        /* Allow entire eeprom update only */
        if ((ee->magic == LAN78XX_EEPROM_MAGIC) &&
            (ee->offset == 0) &&
            (ee->len == 512) &&
            (data[0] == EEPROM_INDICATOR))
                return lan78xx_write_raw_eeprom(dev, ee->offset, ee->len, data);
       else if ((ee->magic == LAN78XX_OTP_MAGIC) &&
>  		 (ee->len == 512) &&
>  		 (data[0] == OTP_INDICATOR_1))
>  		ret = lan78xx_write_raw_otp(dev, ee->offset, ee->len, data);
> +	else if ((ee->magic == LAN78XX_EEPROM_MAGIC) &&
> +		 (ee->offset >= 0 && ee->offset < MAX_EEPROM_SIZE) &&
> +		 (ee->len > 0 && (ee->offset + ee->len) <= MAX_EEPROM_SIZE))
> +		ret = lan78xx_write_raw_eeprom(dev, ee->offset, ee->len, data);
>  
>  	usb_autopm_put_interface(dev->intf);

Hi Nisar

You should explain why this change cannot be folded into the first if
statement.

	Andrew
