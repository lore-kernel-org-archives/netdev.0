From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: qcom/emac: don't try to claim clocks on ACPI systems
Date: Tue, 13 Dec 2016 13:46:31 -0800
Message-ID: <d6683e1c-803d-3859-f125-93fecaa0df02@gmail.com>
References: <1481658930-565-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Christopher Covington <cov@codeaurora.org>,
        alokc@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32989 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932807AbcLMVqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 16:46:35 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so31376pgd.0
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 13:46:35 -0800 (PST)
In-Reply-To: <1481658930-565-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2016 11:55 AM, Timur Tabi wrote:
> On ACPI systems, clocks are not available to drivers directly.  They are
> handled exclusively by ACPI and/or firmware, so there is no clock driver.
> Calls to clk_get() always fail, so we should not even attempt to claim
> any clocks on ACPI systems.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
>  drivers/net/ethernet/qualcomm/emac/emac.c | 22 ++++++++++++----------
>  1 file changed, 12 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
> index ae32f85..b1c1cdc 100644
> --- a/drivers/net/ethernet/qualcomm/emac/emac.c
> +++ b/drivers/net/ethernet/qualcomm/emac/emac.c
> @@ -627,11 +627,12 @@ static int emac_probe(struct platform_device *pdev)
>  	if (ret)
>  		goto err_undo_netdev;
>  
> -	/* initialize clocks */
> -	ret = emac_clks_phase1_init(pdev, adpt);
> -	if (ret) {
> -		dev_err(&pdev->dev, "could not initialize clocks\n");
> -		goto err_undo_netdev;
> +	if (!has_acpi_companion(&pdev->dev)) {

Is there a reason why the check is not moved down inwo
emac_clks_phase{1,2}_init functions? Do you anticipate other
ACPI-related changes in the future that would warrant having this check
moved at a higher level?
-- 
Florian
