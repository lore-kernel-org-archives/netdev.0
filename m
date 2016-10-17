From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH 2/7] net: ethernet: nb8800: Fix module autoload
Date: Mon, 17 Oct 2016 15:09:29 +0100
Message-ID: <yw1xr37fkqxy.fsf@unicorn.mansr.com>
References: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
        <1476713146-26632-3-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
        Sebastian Frias <sf84@laposte.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Philippe Reynes <tremyfr@gmail.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476713146-26632-3-git-send-email-javier@osg.samsung.com>
        (Javier Martinez Canillas's message of "Mon, 17 Oct 2016 11:05:41
        -0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Javier Martinez Canillas <javier@osg.samsung.com> writes:

> If the driver is built as a module, autoload won't work because the module
> alias information is not filled. So user-space can't match the registered
> device with the corresponding module.
>
> Export the module alias information using the MODULE_DEVICE_TABLE() macro.
>
> Before this patch:
>
> $ $ modinfo drivers/net/ethernet/aurora/nb8800.ko | grep alias
> $
>
> After this patch:
>
> $ modinfo drivers/net/ethernet/aurora/nb8800.ko | grep alias
> alias:          of:N*T*Csigma,smp8734-ethernetC*
> alias:          of:N*T*Csigma,smp8734-ethernet
> alias:          of:N*T*Csigma,smp8642-ethernetC*
> alias:          of:N*T*Csigma,smp8642-ethernet
> alias:          of:N*T*Caurora,nb8800C*
> alias:          of:N*T*Caurora,nb8800
>
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

Acked-by: Mans Rullgard <mans@mansr.com>

> ---
>
>  drivers/net/ethernet/aurora/nb8800.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
> index 453dc0967125..d5f2ad1a5a30 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -1357,6 +1357,7 @@ static const struct of_device_id nb8800_dt_ids[] = {
>  	},
>  	{ }
>  };
> +MODULE_DEVICE_TABLE(of, nb8800_dt_ids);
>
>  static int nb8800_probe(struct platform_device *pdev)
>  {
> -- 

-- 
Måns Rullgård
