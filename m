From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next] cxgb4: Reduce resource allocation in kdump
 kernel
Date: Sat, 4 Jun 2016 13:24:43 +0000
Message-ID: <CO2PR11MB008805A31B3921BF3C728F7A975A0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1464975345-12484-1-git-send-email-hariprasad@chelsio.com>
 <BY2PR12MB064802D9AB46EF297736F308C8590@BY2PR12MB0648.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>
To: Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0116.outbound.protection.outlook.com ([157.56.110.116]:27393
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750838AbcFDNYs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 09:24:48 -0400
In-Reply-To: <BY2PR12MB064802D9AB46EF297736F308C8590@BY2PR12MB0648.namprd12.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When is_kdump_kernel() is true, reduce our memory footprint by only using a
> single "Queue Set" and Forcing Master so we can reinitialize the Firmware/Chip.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
...
>         if (q10g > netif_get_num_default_rss_queues())
>                 q10g = netif_get_num_default_rss_queues();
> 
> +       /* Reduce memory usage in kdump environment by using only one queue
> +        * and disable all offload.
> +        */
> +       if (is_kdump_kernel()) {
> +               q10g = 1;
> +               adap->params.offload = 0;
> +       }
> +

Sounds like a common issue that might interest other devices as well.
Perhaps we should change netif_get_num_default_rss_queues() to return 1
when called from a kdump kernel?
