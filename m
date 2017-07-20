From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: Re: [PATCH 000/102] Convert drivers to explicit reset API
Date: Thu, 20 Jul 2017 11:36:55 +0200
Message-ID: <1500543415.2354.37.camel@pengutronix.de>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
         <20170719211515.46a1196c@windsurf>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        Prashant Gaikwad <pgaikwad@nvidia.com>,
        Heiko Stuebner <heiko@sntech.de>,
        Peter Chen <Peter.Chen@nxp.com>,
        Linus Walleij <linus.walleij@linaro.org>,
        dri-devel@lists.freedesktop.org, Marc Dietrich <marvin24@gmx.de>,
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
        Ohad Ben-Cohen <ohad@wizery.com>, linux-pm@vger.kernel.org,
        Thomas Gleixner <tglx
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170719211515.46a1196c@windsurf>
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

Hi Thomas,

On Wed, 2017-07-19 at 21:15 +0200, Thomas Petazzoni wrote:
> Hello,
> 
> On Wed, 19 Jul 2017 17:25:04 +0200, Philipp Zabel wrote:
> > The reset control API has two modes: exclusive access, where the driver
> > expects to have full and immediate control over the state of the reset
> > line, and shared (clock-like) access, where drivers only request reset
> > deassertion while active, but don't care about the state of the reset line
> > while inactive.
> > 
> > Commit a53e35db70d1 ("reset: Ensure drivers are explicit when requesting
> > reset lines") started to transition the reset control request API calls
> > to explicitly state whether the driver needs exclusive or shared reset
> > control behavior.
> > 
> > This series converts all drivers that currently implicitly request
> > exclusive reset controls to the corresponding explicit API call. It is,
> > for the most part, generated from the following semantic patch:
> > 
> > @@
> > expression rstc, dev, id;
> > @@
> > -rstc = reset_control_get(dev, id);
> > +rstc = reset_control_get_exclusive(dev, id);
> 
> I don't know if it has been discussed in the past, so forgive me if it
> has been. Have you considered adding a "int flags" argument to the
> existing reset_control_get_*() functions, rather than introducing
> separate exclusive variants ?
> 
> Indeed, with a "int flags" argument you could in the future add more
> variants/behaviors without actually multiplying the number of
> functions. Something like the "flags" argument for request_irq() for
> example.

I can't find the discussion right now, but I remember we had talked
about this in the past.
Behind the scenes, all the inline API functions already call common
entry points with flags (well, currently separate bool parameters for
shared and optional).
One reason against exposing those as an int flags in the user facing API
is the possibility to accidentally provide a wrong value.

regards
Philipp
