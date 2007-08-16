From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [patch 4/4] Update e1000 driver to use devres.
Date: Thu, 16 Aug 2007 10:09:58 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329036D2426@orsmsx414.amr.corp.intel.com>
References: <20070815190014.GE7294@ifup.org> <D5C1322C3E673F459512FB59E0DDC329036D21B5@orsmsx414.amr.corp.intel.com> <20070816170522.GA4226@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <e1000-devel@lists.sourceforge.net>,
	<teheo@suse.de>
To: "Brandon Philips" <bphilips@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21666 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755558AbXHPRKG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 13:10:06 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070816170522.GA4226@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Now if I insert a return -ENOMEM right after allocating tx_ring:
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -1356,6 +1356,8 @@ e1000_alloc_queues(struct e1000_adapter 
> *adapter)  {
>         adapter->tx_ring = kcalloc(adapter->num_tx_queues,
>                                    sizeof(struct 
> e1000_tx_ring), GFP_KERNEL);
> +
> +       return -ENOMEM;
>         if (!adapter->tx_ring)
>                 return -ENOMEM;
> 
> #insmod
> DEVRES ADD f7a80e80 pcim_release (8 bytes) DEVRES ADD 
> f7a80ca0 devm_free_netdev (4 bytes) DEVRES ADD eb7f0080 
> pcim_iomap_release (24 bytes) DEVRES ADD eb7f0000 
> devm_kzalloc_release (40 bytes)
> e1000_sw_init: Unable to allocate memory for queues DEVRES 
> REL eb7f0000 devm_kzalloc_release (40 bytes) DEVRES REL 
> eb7f0080 pcim_iomap_release (24 bytes) DEVRES REL f7a80ca0 
> devm_free_netdev (4 bytes) DEVRES REL f7a80e80 pcim_release (8 bytes)
> ACPI: PCI interrupt for device 0000:02:00.0 disabled
> e1000: probe of 0000:02:00.0 failed with error -12
> 
> Since we are returning an error from probe the driver core calls
> devres_release_all(dev) which releases all of the resources 
> in the right order.  See really_probe() in drivers/base/dd.c.

This looks fine then to me.  Thanks for the explanation.

-PJ
