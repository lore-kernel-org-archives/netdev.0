From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 3/4] net: mvneta: mmc: get optional axi clk
Date: Wed, 20 Jan 2016 09:51:32 +0100
Message-ID: <20160120095132.29896293@free-electrons.com>
References: <1453277183-5412-1-git-send-email-jszhang@marvell.com>
	<1453277183-5412-4-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <mw@semihalf.com>, <robh+dt@kernel.org>,
	<pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <sebastian.hesselbarth@gmail.com>,
	<linux-arm-kernel@lists.infradead.org>
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:60237 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751785AbcATIve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 03:51:34 -0500
In-Reply-To: <1453277183-5412-4-git-send-email-jszhang@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jisheng Zhang,

On Wed, 20 Jan 2016 16:06:22 +0800, Jisheng Zhang wrote:
> Some platforms may provide more than one clk for the mvneta IP, for
> example Marvell BG4CT provides "core" clk for the mac core, and
> "axi" clk for the AXI bus logic. Obviously this "axi" clk also need to
> be enabled. This patch adds this optional "axi" clk support.
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

Typo in the title, you have "mmc: ", while this patch is not related to
MMC, unless I'm missing something and MMC means something else in this
context.

>  	clk_prepare_enable(pp->clk);
>  
> +	pp->clk_axi = devm_clk_get(&pdev->dev, "axi");
> +	if (!IS_ERR(pp->clk_axi))
> +		clk_prepare_enable(pp->clk_axi);
> +
>  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	pp->base = devm_ioremap_resource(&pdev->dev, res);
>  	if (IS_ERR(pp->base)) {
> @@ -3727,6 +3733,7 @@ err_free_ports:
>  	free_percpu(pp->ports);
>  err_clk:
>  	clk_disable_unprepare(pp->clk);
> +	clk_disable_unprepare(pp->clk_axi);

For the error paths and cleanup steps, I very much prefer when things
are done in the opposite order of the allocation/creation steps. So can
you clk_disable_unprepare() the AXI clock before the core clock ?

>  err_put_phy_node:
>  	of_node_put(phy_node);
>  err_free_irq:
> @@ -3744,6 +3751,7 @@ static int mvneta_remove(struct platform_device *pdev)
>  
>  	unregister_netdev(dev);
>  	clk_disable_unprepare(pp->clk);
> +	clk_disable_unprepare(pp->clk_axi);

Ditto.

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
