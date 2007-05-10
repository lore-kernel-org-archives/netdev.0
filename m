From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Please pull 'upstream-rtl8187' branch of wireless-2.6
Date: Thu, 10 May 2007 13:23:40 +0200
Message-ID: <200705101323.41310.mb@bu3sch.de>
References: <20070508173907.GH6479@tuxdriver.com> <46425564.3040505@garzik.org> <200705092216.26880.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705092216.26880.flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 10 May 2007 04:16:22 Michael Wu wrote:
> > > +	rtl818x_iowrite8(priv, (u8 *)0xFE18, 0x10);
> > > +	rtl818x_iowrite8(priv, (u8 *)0xFE18, 0x11);
> > > +	rtl818x_iowrite8(priv, (u8 *)0xFE18, 0x00);
> > > +	mdelay(200);
> >
> > ditto
> >
> > also, kill the magic numbers
> >
> I have no idea what that does so I don't see the point in moving the number to 
> some define. However, the hardware does seem to work okay without this part 
> so I can remove it if you bothers you so much.

Nah, Jeff. Please don't go this path.
If we have to remove all magic numbers from drivers, we'd have to either
*) Drop reverse engineered drivers like bcm43xx completely.
*) Clutter them with completely useless defines such as
   #define RADIO_UNKNOWN97A_REG	0x97A

Better leave such magic registers/values in the code as-is
and probably convert them to good defines later, if reverse engineering
found out the meaning. That's what I'm doing for bcm43xx and it makes
a _whole_ lot more sense.

> > > +	if (eeprom->reg_data_in)
> > > +		reg |= RTL818X_EEPROM_CMD_WRITE;
> > > +	if (eeprom->reg_data_out)
> > > +		reg |= RTL818X_EEPROM_CMD_READ;
> > > +	if (eeprom->reg_data_clock)
> > > +		reg |= RTL818X_EEPROM_CMD_CK;
> > > +	if (eeprom->reg_chip_select)
> > > +		reg |= RTL818X_EEPROM_CMD_CS;
> > > +
> > > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, reg);
> > > +	udelay(10);
> >
> > questionable delay
> >
> Most likely to prevent hitting the eeprom too fast.

Accessing eeproms is almost always some kind of critical
and timing dependent task on every device. That's because
of the electrical behavior of the eeprom and its bus.

-- 
Greetings Michael.
