From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v3 4/5] net: stmmac: add a glue driver for the Amlogic Meson 8b / GXBB DWMAC
Date: Mon, 05 Sep 2016 11:27:28 +0200
Message-ID: <8189845.3pyN0uTLGL@wuerfel>
References: <20160820093538.9707-1-martin.blumenstingl@googlemail.com> <20160830191906.GD12510@codeaurora.org> <CAFBinCCVUhUVyceGc2capcCPOK8MTsn+RcC9gnrtMVvZUENXtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        peppe.cavallaro-qxv4g6HH51o@public.gmane.org, carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAFBinCCVUhUVyceGc2capcCPOK8MTsn+RcC9gnrtMVvZUENXtQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday, September 4, 2016 8:20:15 PM CEST Martin Blumenstingl wrote:
> 
> >> +     dwmac->m25_div_clk = devm_clk_register(dev, &dwmac->m25_div.hw);
> >> +     if (WARN_ON(PTR_ERR_OR_ZERO(dwmac->m25_div_clk)))
> >> +             return PTR_ERR(dwmac->m25_div_clk);
> >> +
> >> +     return 0;
> >
> > This could be return WARN_ON(PTR_ERR_OR_ZERO(...))
> This would work as well but I prefer the way it is right now (as one
> could easily extend the code without having to touch any existing code
> apart from the last return).
> However, as it's always the case with personal preference: if
> coding-style requires me to change it then I'll do so, just let me
> know.
> 
> I have addressed all other issues you found (thanks for that!) in v4
> (which I am about to send in the next few minutes).


Both of these are fairly unusual. The most common way to write it is

	if (WARN_ON(IS_ERR(dwmac->m25_div_clk)))
		return PTR_ERR(dwmac->m25_div_clk);
   return 0;

However, I now tend to prefer

	ret = PTR_ERR_OR_ZERO(dwmac->m25_div_clk);
	WARN_ON(ret);
	return ret;

which is less likely to cause false-positive warnings when building
with -Wmaybe-uninitialized than any of the other ones.

Please don't use PTR_ERR_OR_ZERO() as a condition, that is what
IS_ERR() is meant for.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
