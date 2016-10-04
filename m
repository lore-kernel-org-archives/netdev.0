From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] i40e: avoid NULL pointer dereference and recursive
 errors on early PCI error
Date: Mon, 03 Oct 2016 23:29:11 -0400 (EDT)
Message-ID: <20161003.232911.145888579502087608.davem@davemloft.net>
References: <1475479872-112822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gpiccoli@linux.vnet.ibm.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752136AbcJDD3P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 23:29:15 -0400
In-Reply-To: <1475479872-112822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon,  3 Oct 2016 00:31:12 -0700

> From: Guilherme G Piccoli <gpiccoli@linux.vnet.ibm.com>
> 
> Although rare, it's possible to hit PCI error early on device
> probe, meaning possibly some structs are not entirely initialized,
> and some might even be completely uninitialized, leading to NULL
> pointer dereference.
> 
> The i40e driver currently presents a "bad" behavior if device hits
> such early PCI error: firstly, the struct i40e_pf might not be
> attached to pci_dev yet, leading to a NULL pointer dereference on
> access to pf->state.
> 
> Even checking if the struct is NULL and avoiding the access in that
> case isn't enough, since the driver cannot recover from PCI error
> that early; in our experiments we saw multiple failures on kernel
> log, like:
> 
>   [549.664] i40e 0007:01:00.1: Initial pf_reset failed: -15
>   [549.664] i40e: probe of 0007:01:00.1 failed with error -15
>   [...]
>   [871.644] i40e 0007:01:00.1: The driver for the device stopped because the
>   device firmware failed to init. Try updating your NVM image.
>   [871.644] i40e: probe of 0007:01:00.1 failed with error -32
>   [...]
>   [872.516] i40e 0007:01:00.0: ARQ: Unknown event 0x0000 ignored
> 
> Between the first probe failure (error -15) and the second (error -32)
> another PCI error happened due to the first bad probe. Also, driver
> started to flood console with those ARQ event messages.
> 
> This patch will prevent these issues by allowing error recovery
> mechanism to remove the failed device from the system instead of
> trying to recover from early PCI errors during device probe.
> 
> CC: <stable@vger.kernel.org>
> Signed-off-by: Guilherme G Piccoli <gpiccoli@linux.vnet.ibm.com>
> Acked-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
