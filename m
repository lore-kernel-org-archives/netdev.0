From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] ixgbevf: delete unneeded call to pci_set_power_state
Date: Wed, 8 Jan 2014 00:16:14 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B73125CEC@ORSMSX101.amr.corp.intel.com>
References: <1389114026-27854-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Julia Lawall <Julia.Lawall@lip6.fr>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38581 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755070AbaAHAQ3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 19:16:29 -0500
In-Reply-To: <1389114026-27854-1-git-send-email-Julia.Lawall@lip6.fr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Julia Lawall
> Sent: Tuesday, January 07, 2014 9:00 AM
> To: Kirsher, Jeffrey T
> Cc: kernel-janitors@vger.kernel.org; Brandeburg, Jesse; Allan, Bruce W;
> Wyborny, Carolyn; Skidmore, Donald C; Rose, Gregory V; Duyck, Alexander H;
> Ronciak, John; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org
> Subject: [PATCH] ixgbevf: delete unneeded call to pci_set_power_state
> 
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> This driver does not need to adjust the power state on suspend, so the
> call to pci_set_power_state in the resume function is a no-op.  Drop it,
> to make the code more understandable.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index a5d3167..5709fb0 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -3226,7 +3226,6 @@ static int ixgbevf_resume(struct pci_dev *pdev)
>  	struct net_device *netdev = adapter->netdev;
>  	u32 err;
> 
> -	pci_set_power_state(pdev, PCI_D0);
>  	pci_restore_state(pdev);
>  	/*
>  	 * pci_restore_state clears dev->state_saved so call
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

Thanks Julia, I have added this patch to our internal queue (covering for Jeff.)
