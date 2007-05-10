From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 05/17] pci: advanced error reporting stub return values
Date: Thu, 10 May 2007 08:48:25 -0700
Message-ID: <20070510084825.2a8d3add@freepuppy>
References: <20070509034949.624934448@linux-foundation.org>
	<20070509035028.751938921@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Tom Long Nguyen <tom.l.nguyen@intel.com>,
	Zhang Yanmin <yanmin.zhang@intel.com>,
	linux-pci@atrey.karlin.mff.cuni.cz
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36121 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754639AbXEJPsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 11:48:31 -0400
In-Reply-To: <20070509035028.751938921@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 08 May 2007 20:49:54 -0700
Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> The stubs for advanced PCI error reporting are wrong. They don't
> match the function return values. This breaks compilation for any
> driver that tries to use these functions (that's the next sky2 patch).
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> --- sky2.orig/include/linux/aer.h	2007-05-08 20:36:21.000000000 -0700
> +++ sky2/include/linux/aer.h	2007-05-08 20:38:04.000000000 -0700
> @@ -14,10 +14,10 @@
>  extern int pci_disable_pcie_error_reporting(struct pci_dev *dev);
>  extern int pci_cleanup_aer_uncorrect_error_status(struct pci_dev *dev);
>  #else
> -#define pci_enable_pcie_error_reporting(dev)		do { } while (0)
> -#define pci_find_aer_capability(dev)			do { } while (0)
> -#define pci_disable_pcie_error_reporting(dev)		do { } while (0)
> -#define pci_cleanup_aer_uncorrect_error_status(dev)	do { } while (0)
> +#define pci_enable_pcie_error_reporting(dev)		(-EINVAL)
> +#define pci_find_aer_capability(dev)			(0)
> +#define pci_disable_pcie_error_reporting(dev)		(-EINVAL)
> +#define pci_cleanup_aer_uncorrect_error_status(dev)	(-EINVAL)
>  #endif
>  
>  #endif //_AER_H_
> 
> --

Greg could you put this in as a bug fix now.
I don't think I'll put in the usage of aer funcs until 2.6.22 -mm, but
hopefully this will be fixed by then.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
