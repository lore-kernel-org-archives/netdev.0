From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 4/5] net: stmmac: add a glue driver for the Amlogic Meson 8b / GXBB DWMAC
Date: Tue, 06 Sep 2016 11:37:58 +0200
Message-ID: <16206001.1636ZmhtjK@wuerfel>
References: <201609050953.67GKeUAU%fengguang.wu@intel.com> <14789887.lyko4Om94p@wuerfel> <CAFBinCAC3c=o1=8DGfiPhw6w6V42jvYLUfHXHpHLe03pw8P=LQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
        linux-amlogic@lists.infradead.org, khilman@baylibre.com,
        carlo@caione.org, mturquette@baylibre.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sboyd@codeaurora.org,
        manabian@gmail.com, davem@davemloft.net
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:59894 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933143AbcIFJjE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 05:39:04 -0400
In-Reply-To: <CAFBinCAC3c=o1=8DGfiPhw6w6V42jvYLUfHXHpHLe03pw8P=LQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, September 5, 2016 9:07:03 PM CEST Martin Blumenstingl wrote:
> On Mon, Sep 5, 2016 at 12:53 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Monday, September 5, 2016 9:37:29 AM CEST kbuild test robot wrote:
> >> All error/warnings (new ones prefixed by >>):
> >>
> >> >> drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c:63:18: error: field 'm250_mux' has incomplete type
> >>      struct clk_mux  m250_mux;
> >>                      ^
> >> >> drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c:67:21: error: field 'm250_div' has incomplete type
> >>      struct clk_divider m250_div;
> >>                         ^
> >>
> >
> > I think this needs a compile-time dependency on COMMON_CLK
> indeed, since we are also a clock provider we have to depend on
> CONFIG_COMMON_CLK.
> 
> That brings up a question though:
> so far the new driver uses the same Kconfig symbol as the "old" driver
> (CONFIG_DWMAC_MESON).
> The "old" driver does not need CONFIG_COMMON_CLK while the new one does.
> I see a few options here:
> 1. simply adding the dependency (as most configurations will have
> CONFIG_COMMON_CLK enabled anyways)

I think that's fine. At least on both ARM multiplatform and ARM64 it is
always defined by definition, and when build testing, it should be possible
to enable it on other architectures as well.

> 2. add some depends on COMMON_CLK || MACH_MESON6 || MACH_MESON8 foo

That doesn't work unless you also put the calls into the clk interface
inside of ugly #ifdef

> 3. use a new Kconfig symbol for new new driver (CONFIG_DWMAC_MESON8B?)

That would be ok as well, probably not necessary.

> And finally regarding your other mail: I have already changed
> WARN_ON(PTR_ERR_OR_ZERO(...)) to WARN_ON(IS_ERR(...)) in v4

Ok, thanks.

	Arnd
