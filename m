From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v2 net-next] net: phy: Add LED mode driver for Microsemi
 PHYs.
Date: Tue, 7 Feb 2017 14:12:23 +0100
Message-ID: <20170207131223.GE31560@lunn.ch>
References: <1485953626-25780-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1485953626-25780-2-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20170201135555.GE4967@lunn.ch>
 <20170207091737.GA24582@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org
To: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170207091737.GA24582-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > > +- vsc8531,led-1-mode : LED mode. Specify how the LED[1] should behave.
> > > +                       Allowed values are define in
> > > +     int rc;
> > > +
> > > +     if (!of_node)
> > > +             return -ENODEV;
> > > +
> > > +     rc = of_property_read_u8(of_node, led, &led_mode);
> > > +     if ((rc == 0) &&
> > > +         ((led_mode > 15) || (led_mode == 7) || (led_mode == 11))) {
> > > +             phydev_err(phydev, "DT %s invalid\n", led);
> > > +             return -EINVAL;
> > > +     } else if (rc == -EINVAL) {
> > > +             return default_mode;
> > > +     }
> > 
> > I don't think you understood my comment about of_property_read_u8()
> > not modifying &led_mode on error. Please read the comment again, and
> > simplify this.
> > 
> 
> If i understand your comment correctly

Nope, you don't.

     rc = of_property_read_u8(of_node, led, &led_mode);

If rc indicates an error, led_mode is not touched. Read the
documentation for this function. So you can simplifiy the code:

	led_mode = default_mode;
	err = of_property_read_u8(of_node, led, &led_mode);
	if (!err && (led_mode > 15 || led_mode == 7) | (led_mode == 11) {
             phydev_err(phydev, "DT %s invalid\n", led);
             return -EINVAL;
	}
	return led_mode;

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
