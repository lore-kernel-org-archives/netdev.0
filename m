From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.27? 2/2] drivers/net/netxen/netxen_nic_hw.c: fix
 printk warnings
Date: Thu, 07 Aug 2008 02:24:02 -0400
Message-ID: <489A9502.2020601@garzik.org>
References: <200807301950.m6UJoDY4013256@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53821 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754948AbYHGGYF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:24:05 -0400
In-Reply-To: <200807301950.m6UJoDY4013256@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_nic_pci_mem_read_direct':
> drivers/net/netxen/netxen_nic_hw.c:1414: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'u64'
> drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_nic_pci_mem_write_direct':
> drivers/net/netxen/netxen_nic_hw.c:1487: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'u64'
> 
> You don't know what type was used for u64 hence they cannot be printed without
> casting.
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/netxen/netxen_nic_hw.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff -puN drivers/net/netxen/netxen_nic_hw.c~drivers-net-netxen-netxen_nic_hwc-fix-printk-warnings drivers/net/netxen/netxen_nic_hw.c
> --- a/drivers/net/netxen/netxen_nic_hw.c~drivers-net-netxen-netxen_nic_hwc-fix-printk-warnings
> +++ a/drivers/net/netxen/netxen_nic_hw.c
> @@ -1411,7 +1411,8 @@ static int netxen_nic_pci_mem_read_direc
>  		(netxen_nic_pci_is_same_window(adapter, off+size-1) == 0)) {
>  		write_unlock_irqrestore(&adapter->adapter_lock, flags);
>  		printk(KERN_ERR "%s out of bound pci memory access. "
> -			"offset is 0x%llx\n", netxen_nic_driver_name, off);
> +			"offset is 0x%llx\n", netxen_nic_driver_name,
> +			(unsigned long long)off);
>  		return -1;
>  	}
>  
> @@ -1484,7 +1485,8 @@ netxen_nic_pci_mem_write_direct(struct n
>  		(netxen_nic_pci_is_same_window(adapter, off+size-1) == 0)) {
>  		write_unlock_irqrestore(&adapter->adapter_lock, flags);
>  		printk(KERN_ERR "%s out of bound pci memory access. "
> -			"offset is 0x%llx\n", netxen_nic_driver_name, off);
> +			"offset is 0x%llx\n", netxen_nic_driver_name,
> +			(unsigned long long)off);
>  		return -1;
>  	}
>  
> _

applied


