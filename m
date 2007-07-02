From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/9] pasemi_mac: Abstract out register access
Date: Mon, 02 Jul 2007 08:32:24 -0400
Message-ID: <4688F058.7040805@pobox.com>
References: <20070622194720.614405000@lixom.net> <20070622200511.GD11723@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51058 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbXGBMc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:32:29 -0400
In-Reply-To: <20070622200511.GD11723@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> Abstract out the PCI config read/write accesses into reg read/write ones, still
> calling the pci accessors on the back end.
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>
> 
> 
> Index: netdev-2.6/drivers/net/pasemi_mac.c
> ===================================================================
> --- netdev-2.6.orig/drivers/net/pasemi_mac.c
> +++ netdev-2.6/drivers/net/pasemi_mac.c
> @@ -81,6 +81,48 @@ MODULE_PARM_DESC(debug, "PA Semi MAC bit
>  
>  static struct pasdma_status *dma_status;
>  
> +static unsigned int read_iob_reg(struct pasemi_mac *mac, unsigned int reg)
> +{
> +	unsigned int val;
> +
> +	pci_read_config_dword(mac->iob_pdev, reg, &val);
> +	return val;
> +}
> +
> +static void write_iob_reg(struct pasemi_mac *mac, unsigned int reg,
> +			  unsigned int val)
> +{
> +	pci_write_config_dword(mac->iob_pdev, reg, val);
> +}
> +
> +static unsigned int read_mac_reg(struct pasemi_mac *mac, unsigned int reg)
> +{
> +	unsigned int val;
> +
> +	pci_read_config_dword(mac->pdev, reg, &val);
> +	return val;
> +}
> +
> +static void write_mac_reg(struct pasemi_mac *mac, unsigned int reg,
> +			  unsigned int val)
> +{
> +	pci_write_config_dword(mac->pdev, reg, val);
> +}
> +
> +static unsigned int read_dma_reg(struct pasemi_mac *mac, unsigned int reg)
> +{
> +	unsigned int val;
> +
> +	pci_read_config_dword(mac->dma_pdev, reg, &val);
> +	return val;
> +}
> +
> +static void write_dma_reg(struct pasemi_mac *mac, unsigned int reg,
> +			  unsigned int val)
> +{
> +	pci_write_config_dword(mac->dma_pdev, reg, val);
> +}

The general concept is fine, but you should use 'u32' and similar 
size-based types for your input and output values.


