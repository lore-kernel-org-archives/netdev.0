From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Aw: [PATCH] [v8] net: emac: emac gigabit ethernet controller driver
Date: Fri, 12 Aug 2016 22:22:58 +0200
Message-ID: <trinity-1978b11f-5ee9-4e10-b88d-ab126cd976e0-1471033378842@3capp-gmx-bs27>
References: <1470951245-13665-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com
To: "Timur Tabi" <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1470951245-13665-1-git-send-email-timur@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I really dont want to be a killjoy, but...

> +		int ret;
> +
> +		skb = __netdev_alloc_skb_ip_align(adpt->netdev,
> +						  adpt->rxbuf_size, GFP_KERNEL);

This is also called in softirq context by the napi handler in which GFP_KERNEL is
not allowed.
You can either extend the refill function by one gfp_t parameter and then call it 
with GFP_KERNEL for the initial rx buffer allocation when the hw is brought up and 
then with GFP_ATOMIC for refilling in the NAPI handler. Or simply always use GFP_ATOMIC.
In the latter case the additional parameter is not needed of course and you can
use netdev_alloc_skb_ip_align() instead of __netdev_alloc_skb_ip_align().

Regards,
Lino
