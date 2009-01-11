From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] asix: Add support for AX88772A devices
Date: Sun, 11 Jan 2009 00:17:04 -0800 (PST)
Message-ID: <20090111.001704.107600670.davem@davemloft.net>
References: <1231602265.9020.17.camel@dhollis-lnx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: dhollis@davehollis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56124
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751097AbZAKIRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 03:17:03 -0500
In-Reply-To: <1231602265.9020.17.camel@dhollis-lnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Hollis <dhollis@davehollis.com>
Date: Sat, 10 Jan 2009 10:44:25 -0500

> @@ -878,20 +885,22 @@ static struct ethtool_ops ax88772_ethtoo
>  
>  static int ax88772_link_reset(struct usbnet *dev)
>  {
> -	u16 mode;
> -	struct ethtool_cmd ecmd;
> +	u16 mode = AX88772_MEDIUM_DEFAULT;
> +	u16 bmcr;
>  
> -	mii_check_media(&dev->mii, 1, 1);
> -	mii_ethtool_gset(&dev->mii, &ecmd);
> -	mode = AX88772_MEDIUM_DEFAULT;
> +	bmcr = asix_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR);

Just out of curiosity, why did you have to change this
function to not use the generic mii_*() routines just
to support this new device variant?
