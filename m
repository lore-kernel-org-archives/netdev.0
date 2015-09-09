From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Use msleep rather then udelay for reset
 delay
Date: Tue, 08 Sep 2015 22:40:57 -0700 (PDT)
Message-ID: <20150908.224057.2198007286151115292.davem@davemloft.net>
References: <1441554659-8419-1-git-send-email-sjoerd.simons@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sjoerd.simons@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441554659-8419-1-git-send-email-sjoerd.simons@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
Date: Sun,  6 Sep 2015 17:50:59 +0200

> @@ -161,11 +161,16 @@ int stmmac_mdio_reset(struct mii_bus *bus)
>  
>  		if (!gpio_request(reset_gpio, "mdio-reset")) {
>  			gpio_direction_output(reset_gpio, active_low ? 1 : 0);
> -			udelay(data->delays[0]);
> +			if (data->delays[0])
> +				msleep((data->delays[0] + 999) / 1000);

Please use something like DIV_ROUND_UP(..., USEC_PER_MSEC) or similar.
