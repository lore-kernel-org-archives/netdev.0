From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 05/10] [TULIP] Defer tulip_select_media() to process
	context
Date: Sat, 26 Aug 2006 17:44:26 +0100
Message-ID: <1156610666.3007.290.camel@localhost.localdomain>
References: <20060826000227.818796000@linux.intel.com>
	 <20060826000303.523391000@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kyle McMartin <kyle@parisc-linux.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:64955 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1422777AbWHZQ1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 12:27:54 -0400
To: Valerie Henson <val_henson@linux.intel.com>
In-Reply-To: <20060826000303.523391000@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Gwe, 2006-08-25 am 17:02 -0700, ysgrifennodd Valerie Henson:
> +static inline void tulip_tx_timeout_complete(struct tulip_private *tp, void __iomem *ioaddr)
> +{
> +	/* Stop and restart the chip's Tx processes. */
> +	tulip_restart_rxtx(tp);
> +	/* Trigger an immediate transmit demand. */
> +	iowrite32(0, ioaddr + CSR1);

In mmio mode it will only be "immediate" if the caller is guaranteed to
read from the device and flush the iowrite ....


