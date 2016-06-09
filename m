From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: fix parameter to dwmac4_set_umac_addr()
Date: Thu, 9 Jun 2016 07:32:32 +0200
Message-ID: <f29642a3-efaa-8f70-2f37-69ec0ce19c2e@st.com>
References: <1465410077-25381-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
	<netdev@vger.kernel.org>
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	<linux-kernel@lists.codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:51281 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161701AbcFIFcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 01:32:47 -0400
In-Reply-To: <1465410077-25381-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/2016 8:21 PM, Ben Dooks wrote:
> The dwmac4_set_umac_addr() takes a struct mac_device_info as
> the first parameter, but is being passed a ioaddr instead from
> dwmac4_set_filter(). Fix the warning/bug by changing the first
> parameter.
>
> drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c:159:46: warning: incorrect type in argument 1 (different address spaces)
> drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c:159:46:    expected struct mac_device_info *hw
> drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c:159:46:    got void [noderef] <asn:2>*ioaddr
>
> Note, only compile tested this as do not have any
> hardware with it in.
>
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> ---
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Alexandre Torgue <alexandre.torgue@st.com>
> Cc: netdev@vger.kernel.org

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> index 4f7283d..44da877 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> @@ -156,7 +156,7 @@ static void dwmac4_set_filter(struct mac_device_info *hw,
>  		struct netdev_hw_addr *ha;
>
>  		netdev_for_each_uc_addr(ha, dev) {
> -			dwmac4_set_umac_addr(ioaddr, ha->addr, reg);
> +			dwmac4_set_umac_addr(hw, ha->addr, reg);
>  			reg++;
>  		}
>  	}
>
