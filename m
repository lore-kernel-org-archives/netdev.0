From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
Date: Wed, 19 Mar 2008 21:26:13 +0100
Message-ID: <20080319202613.GA24710@electric-eye.fr.zoreil.com>
References: <200803052345.06610.florian.fainelli@telecomint.eu> <200803131155.28164.florian.fainelli@telecomint.eu> <20080317223153.GA3462@electric-eye.fr.zoreil.com> <200803191714.52407.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, Felix Fietkau <nbd@openwrt.org>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54744 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964878AbYCSUoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:44:39 -0400
Content-Disposition: inline
In-Reply-To: <200803191714.52407.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <florian.fainelli@telecomint.eu> :
[...]
> +	ret = request_irq(lp->und_irq, &korina_und_interrupt,
> +			IRQF_SHARED | IRQF_DISABLED, "Ethernet Underflow", dev);
> +	if (ret < 0) {
> +		printk(KERN_ERR DRV_NAME "%s: unable to get UND IRQ %d\n",
> +		    dev->name, lp->und_irq);
> +		goto err_free_ovr_irq;
> +	}
> +
> +err_free_ovr_irq:
> +	free_irq(lp->ovr_irq, dev);
> +err_free_tx_irq:
> +	free_irq(lp->tx_irq, dev);
> +err_free_rx_irq:
> +	free_irq(lp->rx_irq, dev);
> +err_release:
> +	korina_free_ring(dev);
> +	goto out;
> +out:
> +	return ret;

*ouch*

Please have some sleep, some coffee (in that order) and write down the
sequence of instructions of the code above when request_irq does _not_
fail.

-- 
Ueimor
