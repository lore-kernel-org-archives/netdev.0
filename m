From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: Re: [PATCH 000/102] Convert drivers to explicit reset API
Date: Mon, 24 Jul 2017 10:33:41 +0200
Message-ID: <1500885221.2391.50.camel@pengutronix.de>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
         <20170719211515.46a1196c@windsurf>
         <1500543415.2354.37.camel@pengutronix.de>
         <20170720123640.43c2ce01@windsurf>
         <1500555312.2354.75.camel@pengutronix.de>
         <CAKdAkRTx8jd8UToz5_EgMmdW3V47i2uo++YvVB_yzytqSA=P1Q@mail.gmail.com>
         <CACRpkdaXOv7mX+b-q1K34CB5w0SWPXCKa21wHaxL7qjf91PJXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Prashant Gaikwad <pgaikwad@nvidia.com>,
        Heiko Stuebner <heiko@sntech.de>,
        Peter Chen <Peter.Chen@nxp.com>,
        DRI <dri-devel@lists.freedesktop.org>,
        Marc Dietrich <marvin24@gmx.de>,
        Rakesh Iyer <riyer@nvidia.com>,
        Peter Meerwald-Stadler <pmeerw@pmeerw.net>,
        linux-clk <linux-clk@vger.kernel.org>,
        Wim Van Sebroeck <wim@iguana.be>,
        Wolfram Sang <wsa@the-dreams.de>,
        Xinliang Liu <z.liuxinliang@hisilicon.com>,
        Chanwoo Choi <cw00.choi@samsung.com>,
        Alan Stern <stern@rowland.harvard.edu>,
        Jiri Slaby <jslaby@suse.com>,
        Michael Turquette <mturquette@baylibre.com>,
        Guenter Roeck <li
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <CACRpkdaXOv7mX+b-q1K34CB5w0SWPXCKa21wHaxL7qjf91PJXQ@mail.gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Sun, 2017-07-23 at 20:41 +0200, Linus Walleij wrote:
> On Thu, Jul 20, 2017 at 10:46 PM, Dmitry Torokhov
> <dmitry.torokhov@gmail.com> wrote:
> > On Thu, Jul 20, 2017 at 5:55 AM, Philipp Zabel <p.zabel@pengutronix.de> wrote:
> 
> >>> What about reset_control_get(struct device *, const char *, int flags)
> >>> to replace all those variants ?
> >>
> >> While I like how this looks, unfortunately (devm_)reset_control_get
> >> already exists without the flags, so we can't change to that with a
> >> gentle transition.
> >
> > This was done for gpiod_get() and its flags argument with horrifying
> > #define-ry, which thankfully was completely hidden from users.
> 
> For your reference:
> 
> commit bae48da237fcedd7ad09569025483b988635efb7
> "gpiolib: add gpiod_get() and gpiod_put() functions"
> 
> commit 39b2bbe3d715cf5013b5c48695ccdd25bd3bf120
> "gpio: add flags argument to gpiod_get*() functions"
> 
> commit 0dbc8b7afef6e4fddcfebcbacbeb269a0a3b06d5
> "gpio: move varargs hack outside #ifdef GPIOLIB"
> 
> commit b17d1bf16cc72a374a48d748940f700009d40ff4
> "gpio: make flags mandatory for gpiod_get functions"
> 
> Retrospectively ... was that really a good idea... it was a LOT
> of trouble to add a flag, maybe it had been better to try and
> just slam all users in a single go.
> 
> But it worked.

Thanks for the hint and the references. It seems this turned out okay,
but I wouldn't dare to introduce such macro horror^Wmagic.
I'd rather have all users converted to the _exclusive/_shared function
calls and maybe then replace the internal __reset_control_get with
Thomas' suggestion.

regards
Philipp
