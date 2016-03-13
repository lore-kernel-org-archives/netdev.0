From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [v6, 5/5] mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0
Date: Sun, 13 Mar 2016 23:26:28 +0100
Message-ID: <4947024.WeMycs2fID@wuerfel>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com> <1457518131-11339-6-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Yangbo Lu <yangbo.lu@nxp.com>, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-clk@vger.kernel.org, linux-i2c@vger.kernel.org,
	iommu@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-mmc@vger.kernel.org, ulf.hansson@linaro.org,
	Zhao Qiang <qiang.zhao@freescale.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>,
	Santosh Shilimkar <ssantosh@kernel.org>, scott.wood@nxp.com,
	Rob Herring <robh+dt@kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Kumar Gala <galak@codeaurora.org>, leoyang.li@nxp.com,
	xiaobo.xie@nxp.com
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <1457518131-11339-6-git-send-email-yangbo.lu@nxp.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 09 March 2016 18:08:51 Yangbo Lu wrote:
> @@ -567,10 +580,20 @@ static void esdhc_init(struct platform_device *pdev, struct sdhci_host *host)
>         struct sdhci_pltfm_host *pltfm_host;
>         struct sdhci_esdhc *esdhc;
>         u16 host_ver;
> +       u32 svr;
>  
>         pltfm_host = sdhci_priv(host);
>         esdhc = sdhci_pltfm_priv(pltfm_host);
>  
> +       fsl_guts_init();
> +       svr = fsl_guts_get_svr();
> +       if (svr) {
> +               esdhc->soc_ver = SVR_SOC_VER(svr);
> +               esdhc->soc_rev = SVR_REV(svr);
> +       } else {
> +               dev_err(&pdev->dev, "Failed to get SVR value!\n");
> +       }
> +

This makes the driver non-portable. Better identify the specific workarounds
based on the compatible string for this device, or add a boolean DT property
for the quirk.

	Arnd
