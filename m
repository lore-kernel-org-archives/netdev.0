From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth: Fix MAC address detection on network card
 (regression in 2.6.23)
Date: Mon, 15 Oct 2007 14:33:21 -0400
Message-ID: <4713B271.9010607@pobox.com>
References: <200710112242.50167.michael.pyne@kdemail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Pyne <michael.pyne@kdemail.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53573 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933765AbXJOSd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 14:33:29 -0400
In-Reply-To: <200710112242.50167.michael.pyne@kdemail.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Pyne wrote:
> Partially revert a change to mac address detection introduced to the forcedeth 
> driver.  The change was intended to correct mac address detection for newer 
> nVidia chipsets where the mac address was stored in reverse order.  One of 
> those chipsets appears to still have the mac address in reverse order (or at 
> least, it does on my system).
> 
> Signed-off-by: Michael J. Pyne <michael.pyne@kdemail.net>
> ---
> The change that broke mac address detection for my card was commit 
> ef756b3e56c68a4d76d9d7b9a73fa8f4f739180f "forcedeth: mac address correct"
> 
> My network card is an nVidia built-in Ethernet card, output from lspci as 
> follows (with text and numeric ids):
> $ lspci | grep Ethernet
> 00:07.0 Bridge: nVidia Corporation MCP61 Ethernet (rev a2)
> $ lspci -n | grep 07.0
> 00:07.0 0680: 10de:03ef (rev a2)
> 
> The vendor id is, of course, nVidia.  The device id corresponds to the 
> NVIDIA_NVENET_19 entry.
> 
> The included patch fixes the MAC address detection on my system.  
> Interestingly, the MAC address appears to be in the range reserved for my 
> motherboard manufacturer (Gigabyte) and not nVidia.
> 
> If you need any further information about my hardware configuration just let 
> me know.
> 
> Regards,
>  - Michael Pyne
> 
> --- a/drivers/net/forcedeth.c       2007-10-11 22:01:26 -0400
> +++ b/drivers/net/forcedeth-new.c   2007-10-11 22:06:52 -0400
> @@ -5513,7 +5513,7 @@ static struct pci_device_id pci_tbl[] = 
>  	},
>  	{	/* MCP61 Ethernet Controller */
>  		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_19),
> -		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|
> DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|
> DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
> +		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|
> DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|
> DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
>  	},
>  	{	/* MCP65 Ethernet Controller */
>  		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_20),

your patch is word-wrapped.  Anyway...

Ayaz -- ACK this patch?



