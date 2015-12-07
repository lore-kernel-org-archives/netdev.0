From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 5/5] stmmac: socfpga: Provide dt node to config ptp clk
 source.
Date: Mon, 7 Dec 2015 14:59:57 +0300
Message-ID: <566574BD.9010204@cogentembedded.com>
References: <1449452324-53858-1-git-send-email-preid@electromag.com.au>
 <1449452324-53858-7-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Reid <preid@electromag.com.au>, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	devicetree@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:33564 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbbLGMAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 07:00:01 -0500
Received: by lbbkw15 with SMTP id kw15so59488487lbb.0
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 03:59:59 -0800 (PST)
In-Reply-To: <1449452324-53858-7-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2015 04:38 AM, Phil Reid wrote:

> Signed-off-by: Phil Reid <preid@electromag.com.au>
> ---
>   Documentation/devicetree/bindings/net/socfpga-dwmac.txt | 2 ++
>   drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c     | 9 +++++++++
>   2 files changed, 11 insertions(+)
>
> diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> index 3a9d679..72d82d6 100644
> --- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> @@ -11,6 +11,8 @@ Required properties:
>   		  designware version numbers documented in stmmac.txt
>    - altr,sysmgr-syscon : Should be the phandle to the system manager node that
>      encompasses the glue register, the register offset, and the register shift.
> + - altr,f2h_ptp_ref_clk use f2h_ptp_ref_clk instead of default eosc1 clock
> +   for ptp ref clk. This affects all emacs as the clock is common.
>
>   Optional properties:
>   altr,emac-splitter: Should be the phandle to the emac splitter soft IP node if
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> index 401383b..3c5bc12 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
[...]
> @@ -171,6 +175,11 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
>   	ctrl &= ~(SYSMGR_EMACGRP_CTRL_PHYSEL_MASK << reg_shift);
>   	ctrl |= val << reg_shift;
>
> +	if(dwmac->f2h_ptp_ref_clk)

    Please run your patches thru scripts/checkpatch.pl (space needed after *if*).

[...]

MBR, Sergei
