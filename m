From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [patch 1/5][RFC] NET: Change pci_enable_device topci_reenable_device to keep device enable balance
Date: Wed, 8 Aug 2007 17:30:29 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702035646@nekter>
References: <20070802224423.GC5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <teheo@suse.de>, "Brandon Philips" <bphilips@suse.de>
To: "Brandon Philips" <brandon@suse.de>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:24937 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764774AbXHHVeF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 17:34:05 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070802224423.GC5181@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandon,

Before slot_reset event is called io_error_detected could be called
(where pci_disable_device() is called), right? 

The pci_reenable_device() will call enable only if the device was
enabled before and would not be enabled if the device were disabled. Is
this the intended behavior?

Ram

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Brandon Philips
> Sent: Thursday, August 02, 2007 3:44 PM
> To: netdev@vger.kernel.org
> Cc: teheo@suse.de; Brandon Philips
> Subject: [patch 1/5][RFC] NET: Change pci_enable_device
> topci_reenable_device to keep device enable balance
> 
> On a slot_reset event pci_disable_device() is never called so calling
> pci_enable_device() will unbalance the enable count.
> 
> Signed-off-by: Brandon Philips <bphilips@suse.de>
> 
> ---
>  drivers/net/e100.c             |    2 +-
>  drivers/net/e1000/e1000_main.c |    2 +-
>  drivers/net/ixgb/ixgb_main.c   |    2 +-
>  drivers/net/s2io.c             |    2 +-
>  4 files changed, 4 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6/drivers/net/e100.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e100.c
> +++ linux-2.6/drivers/net/e100.c
> @@ -2828,7 +2828,7 @@ static pci_ers_result_t e100_io_slot_res
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct nic *nic = netdev_priv(netdev);
> 
> -	if (pci_enable_device(pdev)) {
> +	if (pci_reenable_device(pdev)) {
>  		printk(KERN_ERR "e100: Cannot re-enable PCI device after
> reset.\n");
>  		return PCI_ERS_RESULT_DISCONNECT;
>  	}
> Index: linux-2.6/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
> +++ linux-2.6/drivers/net/e1000/e1000_main.c
> @@ -5270,7 +5270,7 @@ static pci_ers_result_t e1000_io_slot_re
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct e1000_adapter *adapter = netdev->priv;
> 
> -	if (pci_enable_device(pdev)) {
> +	if (pci_reenable_device(pdev)) {
>  		printk(KERN_ERR "e1000: Cannot re-enable PCI device
after
> reset.\n");
>  		return PCI_ERS_RESULT_DISCONNECT;
>  	}
> Index: linux-2.6/drivers/net/ixgb/ixgb_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/ixgb/ixgb_main.c
> +++ linux-2.6/drivers/net/ixgb/ixgb_main.c
> @@ -2294,7 +2294,7 @@ static pci_ers_result_t ixgb_io_slot_res
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct ixgb_adapter *adapter = netdev_priv(netdev);
> 
> -	if(pci_enable_device(pdev)) {
> +	if(pci_reenable_device(pdev)) {
>  		DPRINTK(PROBE, ERR, "Cannot re-enable PCI device after
> reset.\n");
>  		return PCI_ERS_RESULT_DISCONNECT;
>  	}
> Index: linux-2.6/drivers/net/s2io.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/s2io.c
> +++ linux-2.6/drivers/net/s2io.c
> @@ -7833,7 +7833,7 @@ static pci_ers_result_t s2io_io_slot_res
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct s2io_nic *sp = netdev->priv;
> 
> -	if (pci_enable_device(pdev)) {
> +	if (pci_reenable_device(pdev)) {
>  		printk(KERN_ERR "s2io: "
>  		       "Cannot re-enable PCI device after reset.\n");
>  		return PCI_ERS_RESULT_DISCONNECT;
> 
> --
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
