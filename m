From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: Spurious code in commit 1bf40ada6290 ("amd-xgbe: Add support for
 clause 37 auto-negotiation"
Date: Sat, 12 Nov 2016 09:47:44 -0600
Message-ID: <b9c9483a-76d1-b568-d60c-59f24ac5dea5@amd.com>
References: <80c6a7b3-4a03-e087-3638-7048adebbda8@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Kernel Janitors <kernel-janitors@vger.kernel.org>
To: Marion & Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0047.outbound.protection.outlook.com ([104.47.38.47]:9440
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934577AbcKLPtH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Nov 2016 10:49:07 -0500
In-Reply-To: <80c6a7b3-4a03-e087-3638-7048adebbda8@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/2016 8:34 AM, Marion & Christophe JAILLET wrote:
> Hi,
> 
> in commit 1bf40ada6290 ("amd-xgbe: Add support for clause 37
> auto-negotiation"), we can find:
> 
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
> b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
> index 695e982..8bcf4ef 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
>    [...]
>    #define XGBE_AN_CL37_PCS_MODE_MASK    0x06
>    #define XGBE_AN_CL37_PCS_MODE_BASEX    0x00
>    #define XGBE_AN_CL37_PCS_MODE_SGMII    0x04
>    #define XGBE_AN_CL37_TX_CONFIG_MASK    0x08
>    [...]
> 
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
> b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
> index d5bfbe4..723eb90 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
>    [...]
>    /* Set up the Control register */
>    reg = XMDIO_READ(pdata, MDIO_MMD_VEND2, MDIO_VEND2_AN_CTRL);
>    reg &= XGBE_AN_CL37_TX_CONFIG_MASK;
>    reg &= XGBE_AN_CL37_PCS_MODE_MASK;
>    [...]
> 
> the "reg &=" statements look spurious. The 2 constants being 0x06 and
> 0x08, the current code is equivalent to "reg = 0"
> 
> It is likely that "reg |=" (or "reg &= ~") was expected here.

Yes, those should have been "reg &= ~". I didn't find this in my testing
because the register is all zeroes after reset.  I'll submit a patch to
fix that.

Thanks,
Tom

> 
> Best regards,
> CJ
> 
