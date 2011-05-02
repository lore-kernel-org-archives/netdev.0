From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv2 2/2] tg3: Add code to allow ethtool to enable/disable
 loopback.
Date: Sun, 01 May 2011 23:29:03 -0700
Message-ID: <1304317743.7792.24.camel@Joe-Laptop>
References: <1304033599-8395-3-git-send-email-maheshb@google.com>
	 <1304125404-19376-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1116 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753666Ab1EBG3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2011 02:29:06 -0400
In-Reply-To: <1304125404-19376-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-29 at 18:03 -0700, Mahesh Bandewar wrote:
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

trivia:

>  drivers/net/tg3.c |   57 +++++++++++++++++++++++++++++++++++++++++++++++++++++
[]
> @@ -15241,6 +15288,16 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>  	dev->features |= hw_features;
>  	dev->vlan_features |= hw_features;
>  
> +	/*
> +	 * Add loopback capability only for a subset of devices that support
> +	 * MAC-LOOPBACK. Eventually this need to be enhanced to allow INT-PHY
> +	 * loopback for the remaining devices.
> +	 */
> +	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5780 ||
> +			!tg3_flag(tp, CPMU_PRESENT))

The indentation style is a bit out of character for the file.
Aligned to open parenthesis is the style used elsewhere:

	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5780 ||
	    !tg3_flag(tp, CPMU_PRESENT))

like this:

>  	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
>  	    !tg3_flag(tp, TSO_CAPABLE) &&
>  	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {



