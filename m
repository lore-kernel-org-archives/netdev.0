From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Subject: Re: [PATCH v2 net-next] net: phy: Add LED mode driver for Microsemi
 PHYs.
Date: Tue, 7 Feb 2017 14:47:38 +0530
Message-ID: <20170207091737.GA24582@microsemi.com>
References: <1485953626-25780-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1485953626-25780-2-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20170201135555.GE4967@lunn.ch>
Reply-To: <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170201135555.GE4967-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Thank you for given review comments.

On Wed, Feb 01, 2017 at 02:55:55PM +0100, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> On Wed, Feb 01, 2017 at 06:23:46PM +0530, Raju Lakkaraju wrote:
> > From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> >
> > LED Mode:
> > +                       "include/dt-bindings/net/mscc-phy-vsc8531.h".
> > +                       Default value is 1.
> 
> 1 is not very useful. What does it mean? How about:
> 
>                         Default value is LINK_1000_ACTIVITY (1)
> 

Accepted.

> > +- vsc8531,led-1-mode : LED mode. Specify how the LED[1] should behave.
> > +                       Allowed values are define in
> > +     int rc;
> > +
> > +     if (!of_node)
> > +             return -ENODEV;
> > +
> > +     rc = of_property_read_u8(of_node, led, &led_mode);
> > +     if ((rc == 0) &&
> > +         ((led_mode > 15) || (led_mode == 7) || (led_mode == 11))) {
> > +             phydev_err(phydev, "DT %s invalid\n", led);
> > +             return -EINVAL;
> > +     } else if (rc == -EINVAL) {
> > +             return default_mode;
> > +     }
> 
> I don't think you understood my comment about of_property_read_u8()
> not modifying &led_mode on error. Please read the comment again, and
> simplify this.
> 

If i understand your comment correctly, in case of return value -EINVAL, it
should return error. Am i correct?

i would perfer in case of of_property_read_u8( ) returns -EINVAL, 
i would like to configure LEDs with default state. Shall i configure?

Still if you think i did not understand your comments, please write little
bit more.

> > +
> > +     return led_mode;
> > +}
> > +
> >  #else
> >  static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
> >  {
> >       return 0;
> >  }
> > +
> > +static int vsc85xx_dt_led_mode_get(struct phy_device *phydev,
> > +                                char *led,
> > +                                u8 default_mode)
> > +{
> > +     return default_mode;
> > +}
> >  #endif /* CONFIG_OF_MDIO */
> >
> >  static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev, u8 edge_rate)
> > @@ -499,6 +562,13 @@ static int vsc85xx_config_init(struct phy_device *phydev)
> >       if (rc)
> >               return rc;
> >
> > +     rc = vsc85xx_led_cntl_set(phydev, 1, vsc8531->led_1_mode);
> > +     if (rc)
> > +             return rc;
> 
> Blank line please.
> 

Accepted.

> > +     rc = vsc85xx_led_cntl_set(phydev, 0, vsc8531->led_0_mode);
> > +     if (rc)
> > +             return rc;
> > +
> >       rc = genphy_config_init(phydev);
> >
> >       return rc;
> > @@ -555,8 +625,9 @@ static int vsc85xx_read_status(struct phy_device *phydev)
> > +     led_mode = vsc85xx_dt_led_mode_get(phydev, "vsc8531,led-0-mode",
> > +                                        LINK_1000_ACTIVITY);
> > +     if (led_mode < 0)
> > +             return led_mode;
> > +     vsc8531->led_0_mode = led_mode;
> 
> Blank line.
> 

Accepted.

> > +     led_mode = vsc85xx_dt_led_mode_get(phydev, "vsc8531,led-1-mode",
> > +                                        LINK_100_ACTIVITY);
> > +#define AUTONEG_FAULT           12
> > +#define SERIAL_MODE             13
> > +#define FORCE_LED_OFF           14
> > +#define FORCE_LED_ON            15
> 
> You should prefix these with VSC8531_. Otherwise there is potential to
> have issues with two different PHYs defining some of these frequently
> used macros.
> 

Accepted.

>      Andrew

---
Thanks,
Raju.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
