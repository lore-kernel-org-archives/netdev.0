From: Corcodel Marian <asd@marian1000.go.ro>
Subject: Re: [PATCH net v4] r8169:   Disabling multiple invocation on
 rtl_try_msi function.
Date: Thu, 04 Feb 2016 13:04:23 +0200
Message-ID: <1454583863.2404.2.camel@marian1000.go.ro>
References: <1454578538-2544-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-225-121.residential.rdsnet.ro ([5.14.225.121]:34806 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755419AbcBDLE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 06:04:28 -0500
In-Reply-To: <1454578538-2544-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-04 at 11:35 +0200, Corcodel Marian wrote:
> This patch set MSI on probe stage without this patch MSI is set when
> rtl_open occur.
>  Do not need to run rtl_try_msi on multiple times.
> 
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c
> b/drivers/net/ethernet/realtek/r8169.c
> index 30eed0d..b0b43b7 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -8248,6 +8248,9 @@ static int rtl_init_one(struct pci_dev *pdev,
> const struct pci_device_id *ent)
>  
>  	/* Identify chip attached to board */
>  	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
> +	RTL_W8(Cfg9346, Cfg9346_Unlock);
> +	tp->features = rtl_try_msi(tp, cfg);
> +	RTL_W8(Cfg9346, Cfg9346_Lock);
>  
>  	rtl_init_rxcfg(tp);
>  
> @@ -8303,7 +8306,6 @@ static int rtl_init_one(struct pci_dev *pdev,
> const struct pci_device_id *ent)
>  	}
>  	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
>  		tp->features |= RTL_FEATURE_WOL;
> -	tp->features |= rtl_try_msi(tp, cfg);
>  	RTL_W8(Cfg9346, Cfg9346_Lock);
>  
>  	if (rtl_tbi_enabled(tp)) {


Sorry here patch is good but explications is bad.
Is about set first order to run rtl_try_msi and others.
