From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/3] sis190: better message on unknown PHY
Date: Tue, 2 Jun 2009 23:43:35 +0200
Message-ID: <20090602214335.GA24637@electric-eye.fr.zoreil.com>
References: <cover.1244012631.git.birrachiara@tin.it> <20090603095354.GA15649@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Riccardo Ghetta <birrachiara@tin.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50822 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751970AbZFBVlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 17:41:50 -0400
Content-Disposition: inline
In-Reply-To: <20090603095354.GA15649@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Riccardo Ghetta <birrachiara@tin.it> :
[...]
> diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
> index 8322e28..a69f3d2 100644
> --- a/drivers/net/sis190.c
> +++ b/drivers/net/sis190.c
[...]
> @@ -1329,12 +1329,15 @@ static void sis190_init_phy(struct net_device *dev, struct sis190_private *tp,
>  			((mii_status & (BMSR_100FULL | BMSR_100HALF)) ?
>  				LAN : HOME) : p->type;
>  		tp->features |= p->feature;
> -	} else
> +		net_probe(tp, KERN_INFO "%s: %s transceiver at address %d.\n",
> +			pci_name(tp->pci_dev), p->name, phy_id);
> +	} else {
>  		phy->type = UNKNOWN;
> -
> -	net_probe(tp, KERN_INFO "%s: %s transceiver at address %d.\n",
> -		  pci_name(tp->pci_dev),
> -		  (phy->type == UNKNOWN) ? "Unknown PHY" : p->name, phy_id);
> +		net_probe(tp, KERN_INFO
> +			"%s: unknown PHY 0x%x:0x%x transceiver at address %d\n",
                                         ^^^^ ^^^^ 0x%04x:0x%04x ?
> +			pci_name(tp->pci_dev),
> +			phy->id[0], (phy->id[1] & 0xfff0), phy_id);
> +	}
>  }

Please make it the first in the series.

-- 
Ueimor
