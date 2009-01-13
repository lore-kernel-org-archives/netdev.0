From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH v2] powerpc/fs_enet: Add missing irq free in error path.
Date: Tue, 13 Jan 2009 10:28:15 -0600
Message-ID: <606FE12E-797E-4C0C-8FA7-5C162BD959A9@kernel.crashing.org>
References: <49027044.90509@consentry.com> <1D4ED273-13FB-4D2F-82B1-89D2F6F0B9A1@kernel.crashing.org> <490636B4.2010202@consentry.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	Mike Ditto <mditto@consentry.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59121 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299AbZAMQ21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 11:28:27 -0500
In-Reply-To: <490636B4.2010202@consentry.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 27, 2008, at 4:46 PM, Mike Ditto wrote:

> If something goes wrong attaching to phy driver, we weren't freeing
> the IRQ.
>
> Signed-off-by: Mike Ditto <mditto@consentry.com>
> ---
> Reposting to CC netdev list.  (Thanks, Kumar)
>
> diff -r -upN 2.6.28-rc1/drivers/net/fs_enet/fs_enet-main.c NEW/ 
> drivers/net/fs_enet/fs_enet-main.c
> --- 2.6.28-rc1/drivers/net/fs_enet/fs_enet-main.c	2008-10-24  
> 17:54:31.000000000 -0700
> +++ NEW/drivers/net/fs_enet/fs_enet-main.c	2008-10-24  
> 17:57:03.000000000 -0700
> @@ -795,6 +795,7 @@ static int fs_enet_open(struct net_devic
>
> 	err = fs_init_phy(dev);
> 	if (err) {
> +		free_irq(fep->interrupt, dev);
> 		if (fep->fpi->use_napi)
> 			napi_disable(&fep->napi);
> 		return err;
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev

Dave,

This seems to have gotten lost in the shuffle.  Can you please apply.

- k
