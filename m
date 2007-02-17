From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 2/2] natsemi: Support Aculab E1/T1 PMXc cPCI carrier cards
Date: Sat, 17 Feb 2007 15:22:30 -0500
Message-ID: <45D76406.1060002@garzik.org>
References: <20070214100203.413293000@sirena.org.uk> <20070214100227.222896000@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tim Hockin <thockin@hockin.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47691 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696AbXBQUWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:22:33 -0500
In-Reply-To: <20070214100227.222896000@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown wrote:
> Aculab E1/T1 PMXc cPCI carrier card cards present a natsemi on the cPCI
> bus with an oversized EEPROM using a direct MII<->MII connection with no
> PHY.  This patch adds a new device table entry supporting these cards.
> 
> Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

> @@ -811,7 +816,11 @@
>  	np->hands_off = 0;
>  	np->intr_status = 0;
>  	np->eeprom_size = natsemi_pci_info[chip_idx].eeprom_size;
> -	np->ignore_phy = 0;
> +	if (natsemi_pci_info[chip_idx].flags & NATSEMI_FLAG_IGNORE_PHY) {
> +		np->ignore_phy = 1;
> +	} else {
> +		np->ignore_phy = 0;
> +	}


I ACK the patch itself, but since you have to resend anyway, please kill 
the braces surrounding the above single-C-stmt lines.

