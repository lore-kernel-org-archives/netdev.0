From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v8 2/3] net: hisilicon: new hip04 MDIO driver
Date: Thu, 24 Apr 2014 14:28:09 +0200
Message-ID: <201404241428.10248.arnd@arndb.de>
References: <1397869980-21187-1-git-send-email-zhangfei.gao@linaro.org> <201404221630.07865.arnd@arndb.de> <53568398.2030800@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org,
	David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: zhangfei <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <53568398.2030800-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 22 April 2014, zhangfei wrote:
> On 04/22/2014 10:30 PM, Arnd Bergmann wrote:
> > On Tuesday 22 April 2014, zhangfei wrote:
> >> On 04/22/2014 04:22 PM, Arnd Bergmann wrote:

> > But it means that the hip04_mdio driver potentially won't work if connected
> > to something other than a Marvell PHY.
> >
> > I noticed that the marvell_of_reg_init() does this at init time:
> >
> > saved_page = phy_read(phydev, MII_MARVELL_PHY_PAGE);
> > ... /* perform init */
> > if (page_changed)
> >       phy_write(phydev, MII_MARVELL_PHY_PAGE, saved_page);
> >
> > Is this a bug? Maybe it should always set page 0 when leaving
> > this function.
> >
> It is correct behavior return to the original page.
> 
> First get_phy_id, then match driver according to the id, then operation 
> in the specific driver have the chance to run, including 
> marvell_of_reg_init etc.
> 
> Just unlucky the default value of PHY_PAGE after power on is not 0.

Ok, so it's actually not possible to detect this case prior to having
to work around it.

How about adding a DT property as a flag to tell the driver whether
to set the page to zero or not? That would let the driver work
with different types of PHY implementations, or skip the code if
there is firmware that can already set it up to page zero.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
