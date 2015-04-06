From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] stmmac: Add IMG Pistachio platform glue layer
Date: Mon, 06 Apr 2015 16:51:34 -0400 (EDT)
Message-ID: <20150406.165134.2223739588886155438.davem@davemloft.net>
References: <1428018396-11270-1-git-send-email-abrestic@chromium.org>
	<1428018396-11270-2-git-send-email-abrestic@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	govindraj.raja@imgtec.com, james.hartley@imgtec.com
To: abrestic@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428018396-11270-2-git-send-email-abrestic@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Bresticker <abrestic@chromium.org>
Date: Thu,  2 Apr 2015 16:46:36 -0700

> +static void *pistachio_dwmac_setup(struct platform_device *pdev)
> +{
> +	struct pistachio_dwmac_priv_data *pdata;
> +
> +	pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
> +	if (!pdata)
> +		return ERR_PTR(-ENOMEM);
> +
> +	pdata->sys_clk = devm_clk_get(&pdev->dev, "sys");
> +	if (IS_ERR(pdata->sys_clk)) {
> +		dev_err(&pdev->dev, "Failed to get sys clock: %ld\n",
> +			PTR_ERR(pdata->sys_clk));
> +		return pdata->sys_clk;

Please do not store potential error pointers in dynamically allocated
memory.

Put it in a local variable for the devm_clk_get() call, then if it
succeeds and is not an error pointer, place it into pdata->sys_clk.

You must resubmit this entire patch series when updating any aspect
of it.  I'm pre-emptively telling you this because often people think
they can just post a new version of the fixed patch, but that's not
how things work here :-)

Thanks.
