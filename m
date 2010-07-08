From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] igbvf: avoid name clash between PF and VF
Date: Thu, 8 Jul 2010 15:41:57 +0200
Message-ID: <201007081541.57685.arnd@arndb.de>
References: <4C2B0614.9040004@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	Andy Gospodarek <gospo@redhat.com>
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:54465 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189Ab0GHNmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 09:42:15 -0400
In-Reply-To: <4C2B0614.9040004@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 June 2010, Stefan Assmann wrote:
> diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
> index 5e2b2a8..2fb665b 100644
> --- a/drivers/net/igbvf/netdev.c
> +++ b/drivers/net/igbvf/netdev.c
> @@ -2787,7 +2787,7 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
>         netif_carrier_off(netdev);
>         netif_stop_queue(netdev);
> 
> -       strcpy(netdev->name, "eth%d");
> +       strcpy(netdev->name, "veth%d");
>         err = register_netdev(netdev);
>         if (err)
>                 goto err_hw_init;

Note that 'veth' is the name used for a virtual ethernet pair by
drivers/net/veth.c. If a variant of your patch gets applied, it would
probably be useful to use a different naming scheme to avoid confusion
with the veth driver.

	Arnd
