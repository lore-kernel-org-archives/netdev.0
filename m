From: Julia Lawall <julia@diku.dk>
Subject: Re: [patch] vxge: remove duplicated part of check
Date: Fri, 24 Dec 2010 10:34:28 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1012241032120.21838@ask.diku.dk>
References: <20101224061539.GP1936@bicker>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Jon Mason <jon.mason@exar.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:51933 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731Ab0LXJef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Dec 2010 04:34:35 -0500
In-Reply-To: <20101224061539.GP1936@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Dec 2010, Dan Carpenter wrote:

> This is just a cleanup to make the static checkers happy.  We don't need
> to check "own" twice.

It's indeed probably pretty pointless to put if (!A || (B && A)) because 
then B, which may rely on A being true, has already occurred.  Would 
anyone find if (!A || (A && B)) to be useful for readability?  I found 
20-some other occurrences, mostly of the latter type.

julia


> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
> index 42cc298..4c10d6c 100644
> --- a/drivers/net/vxge/vxge-traffic.c
> +++ b/drivers/net/vxge/vxge-traffic.c
> @@ -1240,7 +1240,7 @@ enum vxge_hw_status vxge_hw_ring_rxd_next_completed(
>  	*t_code	= (u8)VXGE_HW_RING_RXD_T_CODE_GET(control_0);
>  
>  	/* check whether it is not the end */
> -	if (!own || ((*t_code == VXGE_HW_RING_T_CODE_FRM_DROP) && own)) {
> +	if (!own || *t_code == VXGE_HW_RING_T_CODE_FRM_DROP) {
>  
>  		vxge_assert(((struct vxge_hw_ring_rxd_1 *)rxdp)->host_control !=
>  				0);
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
