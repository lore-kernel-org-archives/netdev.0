From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [net-next PATCH 3/7] stmmac: dwmac-sti: add PM ops and resume function
Date: Tue, 1 Nov 2016 18:19:42 +0100
Message-ID: <CAGhQ9Vw4XJnz1+8FMDDo90j2r_4U4xX30omQQU=bQmNb3sPA_w@mail.gmail.com>
References: <20161030200507.851-1-manabian@gmail.com> <20161030200507.851-4-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joachim Eastwood <manabian@gmail.com>,
        "peppe.cavallaro" <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33310 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752077AbcKARTn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 13:19:43 -0400
Received: by mail-oi0-f65.google.com with SMTP id i127so18163382oia.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 10:19:43 -0700 (PDT)
In-Reply-To: <20161030200507.851-4-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30 October 2016 at 21:05, Joachim Eastwood <manabian@gmail.com> wrote:
> Implement PM callbacks and driver remove in the driver instead
> of relying on the init/exit hooks in stmmac_platform. This gives
> the driver more flexibility in how the code is organized.
>
> Eventually the init/exit callbacks will be deprecated in favor
> of the standard PM callbacks and driver remove function.
>
> Signed-off-by: Joachim Eastwood <manabian@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 46 +++++++++++++++++++------
>  1 file changed, 36 insertions(+), 10 deletions(-)
> +#ifdef CONFIG_PM_SLEEP
> +static int sti_dwmac_suspend(struct device *dev)
> +{
> +       struct sti_dwmac *dwmac = get_stmmac_bsp_priv(dev);
> +       int ret = stmmac_suspend(dev);
> +
> +       clk_disable_unprepare(dwmac->clk);
> +
> +       return ret;
> +}
> +
> +static int sti_dwmac_resume(struct device *dev)
> +{
> +       struct sti_dwmac *dwmac = get_stmmac_bsp_priv(dev);
> +       struct platform_device *pdev = to_platform_device(dev);
> +
> +       sti_dwmac_init(pdev, dwmac);
> +
> +       return stmmac_resume(dev);
> +}
> +#endif /* CONFIG_PM_SLEEP */
> +
> +SIMPLE_DEV_PM_OPS(sti_dwmac_pm_ops, sti_dwmac_suspend, sti_dwmac_resume);

Just noticed that I am missing a 'static' here.

As this not critical for testing I'll resend the patch set after I
(hopefully) get some response from someone with the hw that can do a
test.


regards,
Joachim Eastwood
