From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/3] net: phy: realtek: add RTL8201F phy-id and
 functions
Date: Sat, 9 Sep 2017 17:55:17 +0200
Message-ID: <20170909155517.GB19117@lunn.ch>
References: <1504875731-3680-1-git-send-email-hayashi.kunihiko@socionext.com>
 <1504875731-3680-4-git-send-email-hayashi.kunihiko@socionext.com>
 <4173a876-3cff-205a-ce87-ce049f419aa0@gmail.com>
 <CAJe_ZhciWBhw5npxEjTUGw2duS7DSfhzP5nzAOy_ig4-1XcPWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Kunihiko Hayashi <hayashi.kunihiko@socionext.com>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Devicetree List <devicetree@vger.kernel.org>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Masami Hiramatsu <masami.hiramatsu@linaro.org>,
        Jongsung Kim <neidhard.kim@lge.com>
To: Jassi Brar <jaswinder.singh@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJe_ZhciWBhw5npxEjTUGw2duS7DSfhzP5nzAOy_ig4-1XcPWw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 09, 2017 at 09:03:05AM +0530, Jassi Brar wrote:
> On 9 September 2017 at 00:21, Florian Fainelli <f.fainelli@gmail.com> wrote:
> > On 09/08/2017 06:02 AM, Kunihiko Hayashi wrote:
> >> From: Jassi Brar <jaswinder.singh@linaro.org>
> >>
> >> Add RTL8201F phy-id and the related functions to the driver.
> >>
> >> The original patch is as follows:
> >> https://patchwork.kernel.org/patch/2538341/
> >>
> >> Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
> >> Signed-off-by: Jassi Brar <jaswinder.singh@linaro.org>
> >> Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
> >> ---
> >>  drivers/net/phy/realtek.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
> >>  1 file changed, 45 insertions(+)
> >>
> >> diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
> >> index 9cbe645..d9974ce 100644
> >> --- a/drivers/net/phy/realtek.c
> >> +++ b/drivers/net/phy/realtek.c
> >> @@ -29,10 +29,23 @@
> >>  #define RTL8211F_PAGE_SELECT 0x1f
> >>  #define RTL8211F_TX_DELAY    0x100
> >>
> >> +#define RTL8201F_ISR         0x1e
> >> +#define RTL8201F_PAGE_SELECT 0x1f
> >
> > We have a page select register define for the RTL8211F right above, so
> > surely we can make that a common definition?
> >
> That is just for the sake of consistency.
> I mean RTL8211 wouldn't look neat among everything else RTL8201.
> 
> Also the page-select offsets just _happen_ to be same value...

If you look at all the other supported PHYs, they all consistently use
the same page register across models. Marvell is always 22, mscc is
always 31, vitesse is always 31.

I would say it is a safe bet that all realtek PHYs will use 0x1f for
page select. So please add a patch which renames RTL8211F_PAGE_SELECT
to RTL821x_PAGE_SELECT.

It is best to do this now. I spent a while cleaning up the mess the
Marvell driver had got into with its page select code. Lots of
duplicate code and defines doing the same thing.

	  Andrew
