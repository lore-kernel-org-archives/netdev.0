From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH 11/19] drivers/net/irda: use for_each_pci_dev()
Date: Tue, 20 Jul 2010 17:33:01 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1007201732370.4741@pobox.suse.cz>
References: <1278173056-11779-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kernel Janitors <kernel-janitors@vger.kernel.org>,
	Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kulikov Vasiliy <segooon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:34582 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760904Ab0GTPdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 11:33:03 -0400
In-Reply-To: <1278173056-11779-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 3 Jul 2010, Kulikov Vasiliy wrote:

> Use for_each_pci_dev() to simplify the code.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
> ---
>  drivers/net/irda/smsc-ircc2.c |    5 +----
>  1 files changed, 1 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
> index d67e484..850ca1c 100644
> --- a/drivers/net/irda/smsc-ircc2.c
> +++ b/drivers/net/irda/smsc-ircc2.c
> @@ -2848,9 +2848,7 @@ static int __init smsc_ircc_preconfigure_subsystems(unsigned short ircc_cfg,
>  	unsigned short ss_device = 0x0000;
>  	int ret = 0;
>  
> -	dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev);
> -
> -	while (dev != NULL) {
> +	for_each_pci_dev(dev) {
>  		struct smsc_ircc_subsystem_configuration *conf;
>  
>  		/*
> @@ -2899,7 +2897,6 @@ static int __init smsc_ircc_preconfigure_subsystems(unsigned short ircc_cfg,
>  					ret = -ENODEV;
>  			}
>  		}
> -		dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev);
>  	}
>  
>  	return ret;

Doesn't seem to hit linux-next as of today. Dave, are you going to merge 
it?

Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
