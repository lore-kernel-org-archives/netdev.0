From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: add new QCA alx ethernet driver
Date: Thu, 16 Aug 2012 06:16:23 -0700
Message-ID: <1345122983.26882.9.camel@joe2Laptop>
References: <1345053189-10326-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qca-linux-team@qualcomm.com,
	nic-devel@qualcomm.com, Xiong Huang <xiong@qca.qualcomm.com>,
	"Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
To: cjren@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345053189-10326-1-git-send-email-cjren@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-08-16 at 01:53 +0800, cjren@qca.qualcomm.com wrote:
> From: Cloud Ren <cjren@qca.qualcomm.com>
> 
> This driver support two new ethernet chipsets:
> 1969:1091 - AR8161 Gigabit Ethernet
> 1969:1090 - AR8162 Fast Ethernet

[]

> diff --git a/drivers/net/ethernet/atheros/alx/alx_main.c b/drivers/net/ethernet/atheros/alx/alx_main.c
[]
> +/*
> + * alx_hw_printk
> + */
> +void alx_hw_printk(const char *level, const struct alx_hw *hw,
> +		   const char *fmt, ...)
> +{
> +	struct va_format vaf;
> +	va_list args;
> +
> +	va_start(args, fmt);
> +	vaf.fmt = fmt;
> +	vaf.va = &args;
> +
> +	if (hw && hw->adpt && hw->adpt->netdev)
> +		__netdev_printk(level, hw->adpt->netdev, &vaf);

Hi Cloud.  Please convert this to

		netdev_printk(level, hw->adpt->netdev, "%pV", &vaf);

I will submit a patch soon to make the __netdev_printk variant static.
