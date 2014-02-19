From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 07/14] r8152: combine PHY reset with set_speed
Date: Wed, 19 Feb 2014 10:41:54 +0800
Message-ID: <3532474F0A1E449C8ABAC51A6F690258@realtek.com.tw>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com> <1392731351-25502-8-git-send-email-hayeswang@realtek.com> <201402190209.s1J29EVG032292@rtits1.realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'netdev' <netdev@vger.kernel.org>, <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>,
	'linux-usb' <linux-usb@vger.kernel.org>
To: 'Florian Fainelli' <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201402190209.s1J29EVG032292@rtits1.realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Florian Fainelli [mailto:f.fainelli@gmail.com] 
> Sent: Wednesday, February 19, 2014 1:19 AM
> To: Hayes Wang
> Cc: netdev; nic_swsd@realtek.com; 
> linux-kernel@vger.kernel.org; linux-usb
> Subject: Re: [PATCH net-next 07/14] r8152: combine PHY reset 
> with set_speed
[...]
> > +static void rtl_phy_reset(struct r8152 *tp)
> > +{
> > +       u16 data;
> > +       int i;
> > +
> > +       clear_bit(PHY_RESET, &tp->flags);
> > +
> > +       data = r8152_mdio_read(tp, MII_BMCR);
> > +
> > +       /* don't reset again before the previous one complete */
> > +       if (data & BMCR_RESET)
> > +               return;
> > +
> > +       data |= BMCR_RESET;
> > +       r8152_mdio_write(tp, MII_BMCR, data);
> > +
> > +       for (i = 0; i < 50; i++) {
> > +               msleep(20);
> > +               if ((r8152_mdio_read(tp, MII_BMCR) & 
> BMCR_RESET) == 0)
> > +                       break;
> > +       }
> > +}
> 
> If you implemented libphy in the driver you would not have to
> duplicate that and you could use "phy_init_hw()" or
> genphy_soft_reset() to perform the BMCR-based software reset.

Thanks for you suggestion. I would study about those.
 
Best Regards,
Hayes
