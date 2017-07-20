From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH 000/102] Convert drivers to explicit reset API
Date: Thu, 20 Jul 2017 13:46:17 -0700
Message-ID: <CAKdAkRTx8jd8UToz5_EgMmdW3V47i2uo++YvVB_yzytqSA=P1Q@mail.gmail.com>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
 <20170719211515.46a1196c@windsurf> <1500543415.2354.37.camel@pengutronix.de>
 <20170720123640.43c2ce01@windsurf> <1500555312.2354.75.camel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Prashant Gaikwad <pgaikwad@nvidia.com>,
        Heiko Stuebner <heiko@sntech.de>,
        Peter Chen <Peter.Chen@nxp.com>,
        Linus Walleij <linus.walleij@linaro.org>,
        DRI <dri-devel@lists.freedesktop.org>,
        Marc Dietrich <marvin24@gmx.de>,
        Rakesh Iyer <riyer@nvidia.com>,
        Peter Meerwald-Stadler <pmeerw@pmeerw.net>,
        linux-clk@vger.kernel.org, Wim Van Sebroeck <wim@iguana.be>,
        Wolfram Sang <wsa@the-dreams.de>,
        Xinliang Liu <z.liuxinliang@hisilicon.com>,
        Chanwoo Choi <cw00.choi@samsung.com>,
        Alan Stern <stern@rowland.harvard.edu>,
        Jiri Slaby <jslaby@suse.com>,
        Michael Turquette <mturquette@baylibre.com>,
        Guenter Roeck <linux@roeck-us.net>,
To: Philipp Zabel <p.zabel@pengutronix.de>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1500555312.2354.75.camel@pengutronix.de>
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

On Thu, Jul 20, 2017 at 5:55 AM, Philipp Zabel <p.zabel@pengutronix.de> wrote:
> Hi Thomas,
>
> On Thu, 2017-07-20 at 12:36 +0200, Thomas Petazzoni wrote:
>> Hello,
>>
>> On Thu, 20 Jul 2017 11:36:55 +0200, Philipp Zabel wrote:
>>
>> > > I don't know if it has been discussed in the past, so forgive me if it
>> > > has been. Have you considered adding a "int flags" argument to the
>> > > existing reset_control_get_*() functions, rather than introducing
>> > > separate exclusive variants ?
>> > >
>> > > Indeed, with a "int flags" argument you could in the future add more
>> > > variants/behaviors without actually multiplying the number of
>> > > functions. Something like the "flags" argument for request_irq() for
>> > > example.
>> >
>> > I can't find the discussion right now, but I remember we had talked
>> > about this in the past.
>> > Behind the scenes, all the inline API functions already call common
>> > entry points with flags (well, currently separate bool parameters for
>> > shared and optional).
>> > One reason against exposing those as an int flags in the user facing API
>> > is the possibility to accidentally provide a wrong value.
>>
>> This is a quite strange argument. You could also accidentally use the
>> wrong variant of the function, just like you could use the wrong flag.
>
> You can't accidentally use no flag at all or a completely bogus value
> with the "plethora of inline functions" variant.
>
>> Once again, the next time you have another parameter for those reset
>> functions, beyond the exclusive/shared variant, you will multiply again
>> by two the number of functions ? You already have the  exclusive/shared
>> and optional/mandatory variants, so 4 variants. When you'll add a new
>> parameter, you'll have 8 variants. Doesn't seem really good.
>
> I'd rather avoid adding more variants, if possible. The complexity
> increases regardless of whether the API is expressed as a bunch of
> functions or as a single function with a bunch of flags.
>
>> What about reset_control_get(struct device *, const char *, int flags)
>> to replace all those variants ?
>
> While I like how this looks, unfortunately (devm_)reset_control_get
> already exists without the flags, so we can't change to that with a
> gentle transition.

This was done for gpiod_get() and its flags argument with horrifying
#define-ry, which thankfully was completely hidden from users.

-- 
Dmitry
