From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] igb/e1000e/e1000/e100: make wol usable
Date: Wed, 22 Jul 2009 13:00:50 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0907221256420.13196@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090721210115.GL8515@gospo.rdu.redhat.com>
 <273D38FBE7C6FE46A1689FCD014A0B8B55D57764@azsmsx505.amr.corp.intel.com>
 <20090722022745.GM8515@gospo.rdu.redhat.com>
 <5f2db9d90907212025k31c3a941v5fd1be9ed171e4c1@mail.gmail.com>
 <20090722193400.GN8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"stable@kernel.org" <stable@kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18700 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755178AbZGVUAw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 16:00:52 -0400
In-Reply-To: <20090722193400.GN8515@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [PATCH] ixgbe: remove unnecessary call to device_init_wakeup
> 
> Calls to device_init_wakeup should not be necessary in drivers that use
> device_set_wakeup_enable since pci_pm_init will set the can_wakeup flag
> for the device when initialized.
> 
> I can't test this since I don't have any of the 82599 KX4 interfaces
> (the only ones capable of WOL), but I did instrument ixgbe_probe and
> know that can_wakeup=1 when device_init_wakeup is removed.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> 
> ---
> 
>  ixgbe_main.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 79f60e8..2f15abf 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -5640,7 +5640,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
>  		adapter->wol = 0;
>  		break;
>  	}
> -	device_init_wakeup(&adapter->pdev->dev, true);
>  	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
>  
>  	/* pick up the PCI bus settings for reporting later */

I need to rebuild one of my boxes in the lab that I do WoL testing on for 
ixgbe devices.  That shouldn't take me long, and I'll test this.  If it 
works as expected, I'll send my ack.

Cheers,
-PJ Waskiewicz
