From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH v2 3/4] net: stmmac: add a glue driver for the Amlogic
 Meson 8b / GXBB DWMAC
Date: Sun, 21 Aug 2016 14:00:39 +0200
Message-ID: <CAFBinCCC4LQUkF17G-LNQWs_EuRiw44V7hep-zDsm-9MQ64VnA@mail.gmail.com>
References: <20160815164100.27766-1-martin.blumenstingl@googlemail.com>
 <20160820093538.9707-1-martin.blumenstingl@googlemail.com>
 <20160820093538.9707-4-martin.blumenstingl@googlemail.com> <CAGhQ9VyWs=sYg7PVrt5r-fM-2t--qAnHyvNXAZXwjkYn5P196g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, Michael Turquette <mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        "peppe.cavallaro" <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
        Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGhQ9VyWs=sYg7PVrt5r-fM-2t--qAnHyvNXAZXwjkYn5P196g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Joachim,

On Sat, Aug 20, 2016 at 11:29 PM, Joachim  Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> +       platform_set_drvdata(pdev, dwmac);
>
> This will not work. The main stmmac driver already uses the driver_data field.
> See: http://lxr.free-electrons.com/source/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c#L3218
>
>
>> +       return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
>
> So calling stmmac_dvr_probe here will overwrite the driver_data field.
>
>
>> +}
>> +
>> +static int meson8b_dwmac_remove(struct platform_device *pdev)
>> +{
>> +       struct meson8b_dwmac *dwmac = platform_get_drvdata(pdev);
>> +
>> +       clk_disable_unprepare(dwmac->m25_div_clk);
>
> Did you test this code? I am pretty sure it will blow up given that
> driver_data is not set to what you expect.
I guess I should've taken a closer look at my kernel config:
CONFIG_DWMAC_MESON=y
Thanks for spotting this issue!

> To get your meson8b_dwmac struct you must retrieve it from plat_dat->bsp_priv.
>
>
> I have some code for a helper to retrieve bsp_priv that I have meant
> to sent to the ML for a while now.
> See: https://github.com/manabian/linux-lpc/commit/c3e155a6e38b9634e4e61aa4eeb4602ede7e44a6
>
> Feel free to add it to your patch set if you want.
>
> Alternatively take a look at the remove function from dwmac-stm32 here:
> https://patchwork.ozlabs.org/patch/619816/
excellent, thanks!

I will send a fixed version as soon as possible


Regards,
Martin
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
