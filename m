From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v8 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Wed, 5 Oct 2016 14:07:02 +0200
Message-ID: <20161005120702.GO5575@lunn.ch>
References: <1475667578-20799-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org
To: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1475667578-20799-1-git-send-email-Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> - As per review comment, Added DT vddmac, slowdown value error check. 

So i said an exact match, which this is not.

How about something like:

static u8 vsc85xx_edge_rate_magic_get(u16 vddmac, u8 slowdown)
{
	u8 vdd;
	u8 sd;

	for (vdd = 0; vdd < ARRAY_SIZE(edge_table); vdd++)
		if (edge_table[vdd].vddmac == vddmac)
			for (sd = 0; sd < MSCC_SLOWDOWN_MAX; sd++)
				if (edge_table[vdd].slowdown[sd] == slowdown)
					return (MSCC_SLOWDOWN_MAX - sd - 1);
 	return -EINVAL;
}

> @@ -197,15 +203,34 @@ static int vsc8531_of_init(struct phy_device *phydev)
  
  	rc = of_property_read_u16(of_node, "vsc8531,vddmac",
  				  &vsc8531->vddmac);
 	if (rc == -EINVAL)
 		vddmac = MSCC_VDDMAC_3300;

  	rc = of_property_read_u8(of_node, "vsc8531,edge-slowdown",
  				 &vsc8531->edge_slowdown);
 	if (rc == -EINVAL)
  		edge_slowdown = 0;

 	vsc8531->rate_magic = edge_rate_magic_get(vddmac, edge_slowdown);
	if (vsc8531->rate_magic < 0) {
 	   dev_err(phydev->dev, "Invalid vsc8531,vddmac or vsc8531,edge-slowdown");
	   return vsc8531->rate_magic;
        }

>  static int vsc8531_of_init(struct phy_device *phydev)
> @@ -232,8 +257,8 @@ static int vsc85xx_config_init(struct phy_device *phydev)
>  	if (rc)
>  		return rc;
>  
>  	rc = vsc85xx_edge_rate_cntl_set(phydev, vsc8531->rate_magic);
>  	if (rc)
>  		return rc;

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
