From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3] net: stmmac: Delete dead code for MDIO registration
Date: Wed, 23 Aug 2017 09:46:02 -0700
Message-ID: <d803f188-826b-706c-2d28-18ee87b8aa0d@gmail.com>
References: <20170823085058.23333-1-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Romain Perier <romain.perier@collabora.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170823085058.23333-1-romain.perier@collabora.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/23/2017 01:50 AM, Romain Perier wrote:
> This code is no longer used, the logging function was changed by commit
> fbca164776e4 ("net: stmmac: Use the right logging functi"). It was
> previously showing information about the type if the IRQ, if it's polled,
> ignored or a normal interrupt. As we don't want information loss, I have
> moved this code to phy_attached_print().
> 
> Fixes: fbca164776e4 ("net: stmmac: Use the right logging functi")

For future submissions, do not truncate the commit subject that you are
referencing.

> Signed-off-by: Romain Perier <romain.perier@collabora.com>

Since this is a fix you should indicate in the patch subject that this
is targeting David's "net" tree, see
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/netdev-FAQ.txt#n85


>  	const char *drv_name = phydev->drv ? phydev->drv->name : "unbound";
> +	char *irq_str;
> +	char irq_num[4];
> +
> +	switch(phydev->irq) {
> +	case PHY_POLL:
> +		irq_str = "POLL";
> +		break;
> +	case PHY_IGNORE_INTERRUPT:
> +		irq_str = "IGNORE";
> +		break;
> +	default:
> +		snprintf(irq_num, sizeof(irq_str), "%d", phydev->irq);

sizeof(irq_str) = 4 or 8 depending on the architecture because it's a
pointer, did not you mean sizeof(irq_num) here instead?

> +		irq_str = irq_num;
> +		break;
> +	}
>  
>  	if (!fmt) {
>  		dev_info(&phydev->mdio.dev, ATTACHED_FMT "\n",
>  			 drv_name, phydev_name(phydev),
> -			 phydev->irq);
> +			 irq_str);
>  	} else {
>  		va_list ap;
>  
>  		dev_info(&phydev->mdio.dev, ATTACHED_FMT,
>  			 drv_name, phydev_name(phydev),
> -			 phydev->irq);
> +			 irq_str);
>  
>  		va_start(ap, fmt);
>  		vprintk(fmt, ap);
> 


-- 
Florian
