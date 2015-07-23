From: Liberman Igal <Igal.Liberman@freescale.com>
Subject: RE: [v3, 5/9] fsl/fman: Add Frame Manager support
Date: Thu, 23 Jul 2015 12:45:50 +0000
Message-ID: <DM2PR03MB383CBFE012027E474F683E3E6820@DM2PR03MB383.namprd03.prod.outlook.com>
References: <1437564138-16592-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>,
	Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>
To: Liberman Igal <Igal.Liberman@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437564138-16592-1-git-send-email-igal.liberman@freescale.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Regards,
Igal Liberman.

> +static struct platform_driver fm_driver = {
> +	.driver = {
> +		   .name = "fsl-fman",
> +		   .of_match_table = fm_match,
> +		   },
> +	.probe = fm_probe,
> +};
> +
> +builtin_platform_driver(fm_driver);
> +
> +static int __init __cold fm_load(void)
> +{
> +	if (platform_driver_register(&fm_driver)) {
> +		pr_crit("platform_driver_register() failed\n");
> +		return -ENODEV;
> +	}
> +
> +	pr_info("Freescale FMan module\n");
> +	return 0;
> +}
> +
> +device_initcall(fm_load);

Please notice, when using builtin_platform_driver, device_initcall(fm_load); becomes redundant. 
Same issue in 2 other places.
I have patches which fix that which were left out of this submission, I'll add them to v4.
