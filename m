From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fs_enet: Fix a memory leak in fs_enet_mdio_probe
Date: Fri, 2 May 2008 11:37:44 -0700
Message-ID: <20080502113744.77e81c7d.akpm@linux-foundation.org>
References: <20080502183118.GA2918@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40616 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760878AbYEBSiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 14:38:15 -0400
In-Reply-To: <20080502183118.GA2918@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 May 2008 13:31:18 -0500 Scott Wood <scottwood@freescale.com> wrote:

> There are more memory leaks in the !PPC_CPM_NEW_BINDING case, but that code
> will disappear soon along with arch/ppc.
> 
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> ---
>  drivers/net/fs_enet/mii-fec.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
> index ba75efc..f0014cf 100644
> --- a/drivers/net/fs_enet/mii-fec.c
> +++ b/drivers/net/fs_enet/mii-fec.c
> @@ -194,7 +194,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
>  
>  	ret = of_address_to_resource(ofdev->node, 0, &res);
>  	if (ret)
> -		return ret;
> +		goto out_res;
>  
>  	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", res.start);
>  
> @@ -236,6 +236,7 @@ out_free_irqs:
>  	kfree(new_bus->irq);
>  out_unmap_regs:
>  	iounmap(fec->fecp);
> +out_res:
>  out_fec:
>  	kfree(fec);
>  out_mii:

It would be nice to credit Daniel Marjamki <danielm77@spray.se> in the
changelog, please.  Perhaps a mention of
http://bugzilla.kernel.org/show_bug.cgi?id=10591 also.

