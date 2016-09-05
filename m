From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH v4 4/5] net: stmmac: add a glue driver for the Amlogic
 Meson 8b / GXBB DWMAC
Date: Mon, 5 Sep 2016 21:07:03 +0200
Message-ID: <CAFBinCAC3c=o1=8DGfiPhw6w6V42jvYLUfHXHpHLe03pw8P=LQ@mail.gmail.com>
References: <201609050953.67GKeUAU%fengguang.wu@intel.com> <14789887.lyko4Om94p@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, kbuild-all-JC7UmRfGjtg@public.gmane.org,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <14789887.lyko4Om94p@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 5, 2016 at 12:53 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Monday, September 5, 2016 9:37:29 AM CEST kbuild test robot wrote:
>> All error/warnings (new ones prefixed by >>):
>>
>> >> drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c:63:18: error: field 'm250_mux' has incomplete type
>>      struct clk_mux  m250_mux;
>>                      ^
>> >> drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c:67:21: error: field 'm250_div' has incomplete type
>>      struct clk_divider m250_div;
>>                         ^
>>
>
> I think this needs a compile-time dependency on COMMON_CLK
indeed, since we are also a clock provider we have to depend on
CONFIG_COMMON_CLK.

That brings up a question though:
so far the new driver uses the same Kconfig symbol as the "old" driver
(CONFIG_DWMAC_MESON).
The "old" driver does not need CONFIG_COMMON_CLK while the new one does.
I see a few options here:
1. simply adding the dependency (as most configurations will have
CONFIG_COMMON_CLK enabled anyways)
2. add some depends on COMMON_CLK || MACH_MESON6 || MACH_MESON8 foo
3. use a new Kconfig symbol for new new driver (CONFIG_DWMAC_MESON8B?)

And finally regarding your other mail: I have already changed
WARN_ON(PTR_ERR_OR_ZERO(...)) to WARN_ON(IS_ERR(...)) in v4


Regards,
Martin
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
