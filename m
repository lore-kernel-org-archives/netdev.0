From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2.6.20] ibm_emac: Use ARRAY_SIZE macro when appropriate
Date: Mon, 5 Feb 2007 23:22:06 +0300
Message-ID: <20070205202206.GD11055@martell.zuzino.mipt.ru>
References: <20070205165429.GD3896@Ahmed> <20070205165916.GK3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebs@ebshome.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:1865 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933298AbXBEUWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 15:22:07 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2241766nfa
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 12:22:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20070205165916.GK3896@Ahmed>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 05, 2007 at 06:59:16PM +0200, Ahmed S. Darwish wrote:
> A patch to use ARRAY_SIZE macro already defined in kernel.h.

OK, but checks you're changing are strange. idx there is signed so

	BUG_ON(idx < 0 || idx > ARRAY_SIZE());

should be more appropriate.

> --- a/drivers/net/ibm_emac/ibm_emac_debug.c
> +++ b/drivers/net/ibm_emac/ibm_emac_debug.c
> @@ -132,7 +132,7 @@ void emac_dbg_register(int idx, struct ocp_enet_private *dev)
>  {
>  	unsigned long flags;
>  
> -	if (idx >= sizeof(__emacs) / sizeof(__emacs[0])) {
> +	if (idx >= ARRAY_SIZE(__emacs)) {

no __vi, no cookie. :)

>  		printk(KERN_WARNING
>  		       "invalid index %d when registering EMAC for debugging\n",
>  		       idx);
> @@ -148,7 +148,7 @@ void mal_dbg_register(int idx, struct ibm_ocp_mal *mal)
>  {
>  	unsigned long flags;
>  
> -	if (idx >= sizeof(__mals) / sizeof(__mals[0])) {
> +	if (idx >= ARRAY_SIZE(__mals)) {
>  		printk(KERN_WARNING
>  		       "invalid index %d when registering MAL for debugging\n",
>  		       idx);

