From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/6] drivers/net/fs_enet: remove null pointer
	dereference
Date: Mon, 12 May 2008 18:51:42 +0200
Message-ID: <20080512165142.GC22190@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.64.0805121537590.3694@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	jgarzik@pobox.com
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38005 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754031AbYELRPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 13:15:15 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805121537590.3694@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julia Lawall <julia@diku.dk> :
[...]
> diff -u -p a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
> --- a/drivers/net/fs_enet/fs_enet-main.c	2008-04-27 11:41:11.000000000 +0200
> +++ b/drivers/net/fs_enet/fs_enet-main.c	2008-05-12 09:41:52.000000000 +0200
> @@ -1093,7 +1093,7 @@ err:
>  		if (registered)
>  			unregister_netdev(ndev);
>  
> -		if (fep != NULL) {
> +		if (fep && fep->ops) {
>  			(*fep->ops->free_bd)(ndev);
>  			(*fep->ops->cleanup_data)(ndev);
>  		}

Extra cookies for the nice soul who:
- removes the 'if (registered)' test (it can not happen)
- uses different error lablels and unrolls the error path. I can not claim
  that the current error path is wrong but it would not hurt if it was more
  trivially balanced.

-- 
Ueimor
