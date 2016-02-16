From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: ravb: Possible Regression In "net: phy: Avoid polling PHY with PHY_IGNORE_INTERRUPTS"
Date: Tue, 16 Feb 2016 08:42:04 +0100
Message-ID: <CAMuHMdXvnY0i69jSfxk_2K0Ac0PtjF7G7QMXKOh6KOLQE8MsMg@mail.gmail.com>
References: <20160216032642.GE23315@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160216032642.GE23315@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Simon,

On Tue, Feb 16, 2016 at 4:26 AM, Simon Horman <horms@verge.net.au> wrote:
> I have observed what appears to be a regression in the ravb ethernet driver
> caused by d5c3d84657db ("net: phy: Avoid polling PHY with
> PHY_IGNORE_INTERRUPTS").
>
> When booting net-next configured with the ARM64 defconfig on the Renesas
> r8a7795/salvator-x I see the following and the ravb is unable to access the
> network. With the above mentioned patch reverted I am able to boot to
> user-space using nfsroot.

The ravb interrupt is connected to a GPIO controller, which is
runtime-suspended and thus not serving the interrupt.

Cfr. "[PATCH/RFC] gpio: rcar: Add Runtime PM handling for interrupts"
(http://www.spinics.net/lists/linux-renesas-soc/msg00532.html).

I assume it worked before as the PHY driver polled the PHY instead of relying
solely on the interrupt.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
