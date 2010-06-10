From: walter harms <wharms@bfs.de>
Subject: Re: [patch] enic: cleanup vic_provinfo_alloc()
Date: Thu, 10 Jun 2010 11:22:49 +0200
Message-ID: <4C10AEE9.4090804@bfs.de>
References: <20100610075903.GL5483@bicker>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:18264 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752931Ab0FJJXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 05:23:35 -0400
In-Reply-To: <20100610075903.GL5483@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Carpenter schrieb:
> If oui were a null variable then vic_provinfo_alloc() would leak memory.
> But this function is only called from one place and oui is not null so 
> I removed the check.
> 
> I also moved the memory allocation down a line so it was easier to spot.
> (No one ever reads variable declarations).
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/drivers/net/enic/vnic_vic.c b/drivers/net/enic/vnic_vic.c
> index d769772..0a35085 100644
> --- a/drivers/net/enic/vnic_vic.c
> +++ b/drivers/net/enic/vnic_vic.c
> @@ -25,9 +25,10 @@
>  
>  struct vic_provinfo *vic_provinfo_alloc(gfp_t flags, u8 *oui, u8 type)
>  {
> -	struct vic_provinfo *vp = kzalloc(VIC_PROVINFO_MAX_DATA, flags);
> +	struct vic_provinfo *vp;
>  
> -	if (!vp || !oui)
> +	vp = kzalloc(VIC_PROVINFO_MAX_DATA, flags);
> +	if (!vp)
>  		return NULL;
>  
>  	memcpy(vp->oui, oui, sizeof(vp->oui));
> --


This looks like memdup() ?

re,
 wh
