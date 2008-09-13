From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] Fix dead 21041 ethernet after ifconfig down
Date: Sat, 13 Sep 2008 12:05:09 -0600
Message-ID: <20080913180509.GA8392@colo.lackof.org>
References: <20080912211919.1C36FC2AFD@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	kyle@parisc-linux.org, tbm@cyrius.com
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:34569 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752199AbYIMSFW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 14:05:22 -0400
Content-Disposition: inline
In-Reply-To: <20080912211919.1C36FC2AFD@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2008 at 11:19:19PM +0200, Thomas Bogendoerfer wrote:
> The de2104x did a pci_disable_device() in it's close function, but
> the open function never does a pci_enable_device() and assumes that
> the device is already enabled. Considering that downing the interface
> is just a temporary thing the pci_disable_device() isn't a pretty good
> idea and removing it from the close function just fixes the bug.

Thomas,
Thanks for the patch!

The de2104 driver is calling pci_enable_device() in it's .probe routine
and calls pci_disable_device in it's .remove function.
It never occurred to me a NIC driver would call either pci function
from someplace else as well.

> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

> ---
> 
>  drivers/net/tulip/de2104x.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
> index 9281d06..f54c450 100644
> --- a/drivers/net/tulip/de2104x.c
> +++ b/drivers/net/tulip/de2104x.c
> @@ -1418,7 +1418,6 @@ static int de_close (struct net_device *dev)
>  
>  	de_free_rings(de);
>  	de_adapter_sleep(de);
> -	pci_disable_device(de->pdev);
>  	return 0;
>  }
>  
