From: Auke Kok <sofar@foo-projects.org>
Subject: Re: Subject: [PATCH 1/2]: e100 disable device on PCI error
Date: Thu, 29 Jun 2006 13:19:41 -0700
Message-ID: <44A435DD.50701@foo-projects.org>
References: <20060629200644.GA29526@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Rajesh Shah <rajesh.shah@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	"bibo,mao" <bibo.mao@intel.com>, linux-kernel@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:22807 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S932411AbWF2UU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 16:20:27 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060629200644.GA29526@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> A recent patch in -mm3 titled 
>   "gregkh-pci-pci-don-t-enable-device-if-already-enabled.patch"
> causes pci_enable_device() to be a no-op if the kernel thinks
> that the device is already enabled.  This change breaks the
> PCI error recovery mechanism in the e100 device driver, since, 
> after PCI slot reset, the card is no longer enabled. This is 
> a trivial fix for this problem. Tested.
> 
> Please submit uptream.

Ack!

I'm preparing a set of e100 patches at the moment, and will include this one 
with them.

Cheers,

Auke


> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> 
> ----
>  drivers/net/e100.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> Index: linux-2.6.17-mm3/drivers/net/e100.c
> ===================================================================
> --- linux-2.6.17-mm3.orig/drivers/net/e100.c	2006-06-27 11:39:08.000000000 -0500
> +++ linux-2.6.17-mm3/drivers/net/e100.c	2006-06-29 14:18:40.000000000 -0500
> @@ -2742,6 +2742,7 @@ static pci_ers_result_t e100_io_error_de
>  	/* Detach; put netif into state similar to hotplug unplug. */
>  	netif_poll_enable(netdev);
>  	netif_device_detach(netdev);
> +	pci_disable_device(pdev);
>  
>  	/* Request a slot reset. */
>  	return PCI_ERS_RESULT_NEED_RESET;
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
