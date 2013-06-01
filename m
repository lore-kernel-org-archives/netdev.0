From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: [patch -next] bnx2x: fix a power state test
Date: Sat, 1 Jun 2013 14:53:46 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AC61B5F@SJEXCHMB10.corp.ad.broadcom.com>
References: <20130531075840.GA28370@debian>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: "Dan Carpenter" <dan.carpenter@oracle.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2586 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506Ab3FAOxx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 10:53:53 -0400
In-Reply-To: <20130531075840.GA28370@debian>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> PCI_D0 is zero so the original test is never true.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> I don't have the hardware to test this, and I'm not positive on it.
> Buyer beware!
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> index 263950c..a9a1609 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> @@ -1391,7 +1391,7 @@ static bool bnx2x_is_nvm_accessible(struct bnx2x
> *bp)
>  		rc = pci_read_config_word(bp->pdev,
>  					  bp->pm_cap + PCI_PM_CTRL, &pm);
> 
> -	if ((rc && !netif_running(dev)) || (!rc && ((pm & PCI_D0) != PCI_D0)))
> +	if ((rc && !netif_running(dev)) || (!rc && pm != PCI_D0))
>  		return false;

Hi Dan,

Thanks for the catch, but I think your fix might be incomplete; It should probably be
+	if ((rc && !netif_running(dev)) || (!rc && ((pm & PCI_PM_CTRL_STATE_MASK) != PCI_D0)))
Otherwise the condition will fail if other bits are set in the PM control register.

Thanks,
Yuval
