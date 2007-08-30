From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 1/3] netxen: Avoid firmware load in PCI probe
Date: Thu, 30 Aug 2007 18:58:36 -0300
Message-ID: <20070830215836.GC17050@ghostprotocols.net>
References: <20070828115324.839681763@netxen.com> <20070828115603.166212155@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, rob@netxen.com
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:50470 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbXH3V6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 17:58:45 -0400
Received: by wx-out-0506.google.com with SMTP id h31so610330wxd
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2007 14:58:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070828115603.166212155@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Aug 28, 2007 at 05:23:25PM +0530, dhananjay@netxen.com escreveu:
> Loading firmware during PCI probe can lead to incorrect initialization,
> rendering the card unusable until next reboot.  This was introduced a while
> ago as a workaround for firmware bug, a better workaround was submitted for
> this a while ago. So removing original hack that loads firmware during probe.
> 
> Signed-off by: Dhananjay Phadke <dhananjay@netxen.com>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

I was having these problems and after applying this patch the NIC is
back working, thank you for fixing this!

- Arnaldo
 
> Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
> ===================================================================
> --- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
> +++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
> @@ -639,10 +639,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
>  			NETXEN_CRB_NORMALIZE(adapter,
>  				NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
>  		/* Handshake with the card before we register the devices. */
> -		writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
> -		netxen_pinit_from_rom(adapter, 0);
> -		msleep(1);
> -		netxen_load_firmware(adapter);
>  		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
>  	}
