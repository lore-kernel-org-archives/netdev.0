From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 chips on some Intel D945GSEJT boards fail to work after
	PXE boot
Date: Tue, 6 Oct 2009 23:56:01 +0200
Message-ID: <20091006215601.GA10692@electric-eye.fr.zoreil.com>
References: <4ABA535E.2010801@onelan.com> <20090923205723.GA28058@electric-eye.fr.zoreil.com> <4ABB5435.6040609@onelan.com> <20090930220702.GA15415@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Simon Farnsworth <simon.farnsworth@onelan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:49306 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932816AbZJFVum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 17:50:42 -0400
Content-Disposition: inline
In-Reply-To: <20090930220702.GA15415@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> @@ -2200,6 +3075,11 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
>  	if (!tp->pcie_cap && netif_msg_probe(tp))
>  		dev_info(&pdev->dev, "no PCI Express capability\n");
> +	else {
> +		pci_write_config_word(pdev, tp->pcie_cap + PCI_EXP_DEVSTA,
> +				      PCI_EXP_DEVSTA_CED | PCI_EXP_DEVSTA_NFED |
> +				      PCI_EXP_DEVSTA_FED | PCI_EXP_DEVSTA_URD);
> +	}
>  
>  	RTL_W16(IntrMask, 0x0000);
>  

Can you check if this part of the patch is required to fix
your issue ?

I'd rather avoid including it under the 8168d support banner
if it is not needed.

-- 
Ueimor
