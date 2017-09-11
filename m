From: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH net-next 3/3] net: phy: realtek: add RTL8201F phy-id and functions
Date: Mon, 11 Sep 2017 16:48:03 +0900
Message-ID: <20170911164803.6720.4A936039@socionext.com>
References: <CAJe_ZhciWBhw5npxEjTUGw2duS7DSfhzP5nzAOy_ig4-1XcPWw@mail.gmail.com> <20170909155517.GB19117@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Devicetree List <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        Masami Hiramatsu <masami.hiramatsu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jongsung Kim <neidhard.kim-Hm3cg6mZ9cc@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170909155517.GB19117-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,
Thank your for reviewing.

On Sat, 9 Sep 2017 17:55:17 +0200 <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:

> On Sat, Sep 09, 2017 at 09:03:05AM +0530, Jassi Brar wrote:
> > On 9 September 2017 at 00:21, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > > On 09/08/2017 06:02 AM, Kunihiko Hayashi wrote:
> > >> From: Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > >>
> > >> Add RTL8201F phy-id and the related functions to the driver.
> > >>
> > >> The original patch is as follows:
> > >> https://patchwork.kernel.org/patch/2538341/
> > >>
> > >> Signed-off-by: Jongsung Kim <neidhard.kim-Hm3cg6mZ9cc@public.gmane.org>
> > >> Signed-off-by: Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > >> Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
> > >> ---
> > >>  drivers/net/phy/realtek.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
> > >>  1 file changed, 45 insertions(+)
> > >>
> > >> diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
> > >> index 9cbe645..d9974ce 100644
> > >> --- a/drivers/net/phy/realtek.c
> > >> +++ b/drivers/net/phy/realtek.c
> > >> @@ -29,10 +29,23 @@
> > >>  #define RTL8211F_PAGE_SELECT 0x1f
> > >>  #define RTL8211F_TX_DELAY    0x100
> > >>
> > >> +#define RTL8201F_ISR         0x1e
> > >> +#define RTL8201F_PAGE_SELECT 0x1f
> > >
> > > We have a page select register define for the RTL8211F right above, so
> > > surely we can make that a common definition?
> > >
> > That is just for the sake of consistency.
> > I mean RTL8211 wouldn't look neat among everything else RTL8201.
> > 
> > Also the page-select offsets just _happen_ to be same value...
> 
> If you look at all the other supported PHYs, they all consistently use
> the same page register across models. Marvell is always 22, mscc is
> always 31, vitesse is always 31.
> 
> I would say it is a safe bet that all realtek PHYs will use 0x1f for
> page select. So please add a patch which renames RTL8211F_PAGE_SELECT
> to RTL821x_PAGE_SELECT.
> 
> It is best to do this now. I spent a while cleaning up the mess the
> Marvell driver had got into with its page select code. Lots of
> duplicate code and defines doing the same thing.
> 
> 	  Andrew

I see. In case of renaming to RTL821x_PAGE_SELECT, 
I think that I'll make a patch series as realtek PHY series including this
patch independent from the series of MAC driver.

---
Best Regards,
Kunihiko Hayashi


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
