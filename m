From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Mon, 26 Jun 2006 22:06:01 -0400
Message-ID: <44A09289.4040200@garzik.org>
References: <20060626212547.GE30706@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:31701 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030597AbWF0CGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 22:06:03 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060626212547.GE30706@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> +	assert(bcm->mac_suspended >= 0);
> +	if (bcm->mac_suspended == 0) {
> +		bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
> +		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
> +		                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
> +				& ~BCM43xx_SBF_MAC_ENABLED);
> +		bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
> +		for (i = 100000; i; i--) {
> +			tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
> +			if (tmp & BCM43xx_IRQ_READY)
> +				goto out;
> +			udelay(10);
> +		}
> +		printkl(KERN_ERR PFX "MAC suspend failed\n");
>  	}


NAK this super-long delay...  should be done in a workqueue, looks like?

ACK everything else.

	Jeff


