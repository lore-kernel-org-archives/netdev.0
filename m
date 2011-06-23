From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] ssb: use pci_dev->revision
Date: Thu, 23 Jun 2011 17:09:08 +0200
Message-ID: <20110623170908.1417f933@maggie>
References: <201106231849.53030.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:50064 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758983Ab1FWPJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2011 11:09:19 -0400
In-Reply-To: <201106231849.53030.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jun 2011 18:49:52 +0400
Sergei Shtylyov <sshtylyov@ru.mvista.com> wrote:

> The bus scan code reads PCI revision ID from the PCI configuration register
> while it's already stored by PCI subsystem in the 'revision' field of 'struct
> pci_dev'...
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
> ---
> The patch is against the recent Linus' tree.
> 
> There's another place where the revision ID register is read but as 16-bit
> entity (probably by mistake though), so I didn't convert it...

Where is that?

>  drivers/ssb/scan.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> Index: linux-2.6/drivers/ssb/scan.c
> ===================================================================
> --- linux-2.6.orig/drivers/ssb/scan.c
> +++ linux-2.6/drivers/ssb/scan.c
> @@ -310,8 +310,7 @@ int ssb_bus_scan(struct ssb_bus *bus,
>  	} else {
>  		if (bus->bustype == SSB_BUSTYPE_PCI) {
>  			bus->chip_id = pcidev_to_chipid(bus->host_pci);
> -			pci_read_config_byte(bus->host_pci, PCI_REVISION_ID,
> -					     &bus->chip_rev);
> +			bus->chip_rev = bus->host_pci->revision;
>  			bus->chip_package = 0;
>  		} else {
>  			bus->chip_id = 0x4710;
> 

