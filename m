From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 01/22] bnx2x: Support probing and removing
 of VF device
Date: Mon, 10 Dec 2012 13:35:19 -0500 (EST)
Message-ID: <20121210.133519.2048543022289027034.davem@davemloft.net>
References: <1355154406-10855-1-git-send-email-ariele@broadcom.com>
	<1355154406-10855-2-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab2LJSfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 13:35:22 -0500
In-Reply-To: <1355154406-10855-2-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Mon, 10 Dec 2012 17:46:25 +0200

>  static void bnx2x_get_pcie_width_speed(struct bnx2x *bp, int *width, int *speed)
>  {
> -	u32 val = REG_RD(bp, PCICFG_OFFSET + PCICFG_LINK_CONTROL);
> +	u32 val = 0;
> +	pci_read_config_dword(bp->pdev, PCICFG_LINK_CONTROL, &val);

Please put an empty line between function local variable declarations
and actual code.

> @@ -12023,85 +12057,115 @@ static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev,
>  	 * If MSI-X is not supported - return number of SBs needed to support
>  	 * one fast path queue: one FP queue + SB for CNIC
>  	 */
> -	if (!pos)
> +	if (!pos) {
> +		pr_info("no msix capability found");
>  		return 1 + cnic_cnt;
> +	}
> +
> +	pr_info("msix capability found");
>  

Use dev_info(), netdev_info(), or similar, rather than plain
pr_info().
