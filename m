From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] stmmac: platform: Move plat_dat checking earlier
Date: Thu, 27 Nov 2014 15:52:20 +0300
Message-ID: <54771E84.20806@cogentembedded.com>
References: <1417058072-22527-1-git-send-email-chenhc@lemote.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Huacai Chen <chenhc@lemote.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:46717 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbaK0MwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 07:52:23 -0500
Received: by mail-lb0-f177.google.com with SMTP id 10so4038093lbg.22
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 04:52:22 -0800 (PST)
In-Reply-To: <1417058072-22527-1-git-send-email-chenhc@lemote.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/27/2014 6:14 AM, Huacai Chen wrote:

> Original code only check/alloc plat_dat for the CONFIG_OF case, this
> patch check/alloc it earlier and unconditionally to avoid kernel build
> warnings:

> drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:275
> stmmac_pltfr_probe() warn: variable dereferenced before check 'plat_dat'

> Signed-off-by: Huacai Chen <chenhc@lemote.com>
> ---
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   18 +++++++++---------
>   1 files changed, 9 insertions(+), 9 deletions(-)

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 5b0da39..d254950 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -265,6 +265,15 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
>
>   	plat_dat = dev_get_platdata(&pdev->dev);
>
> +	if (!plat_dat)
> +		plat_dat = devm_kzalloc(&pdev->dev,
> +				sizeof(struct plat_stmmacenet_data),
> +				GFP_KERNEL);

    Please start the continuation lines exactly under & on the first line.

[...]

WBR, Sergei
