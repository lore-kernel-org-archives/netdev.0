From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.27] myri10ge: myri10ge_fw_name also overrides the
 rss firmware
Date: Thu, 14 Aug 2008 04:28:53 -0400
Message-ID: <48A3ECC5.3050006@garzik.org>
References: <48A33090.2060208@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41413 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754294AbYHNI24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 04:28:56 -0400
In-Reply-To: <48A33090.2060208@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> When myri10ge_fw_name is given, use it to override the rss firmware
> name as well.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-08-12 16:43:26.000000000 +0200
> +++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-08-12 16:43:53.000000000 +0200
> @@ -3548,7 +3548,11 @@
>  
>  	/* try to load the slice aware rss firmware */
>  	old_fw = mgp->fw_name;
> -	if (old_fw == myri10ge_fw_aligned)
> +	if (myri10ge_fw_name != NULL) {
> +		dev_info(&mgp->pdev->dev, "overriding rss firmware to %s\n",
> +			 myri10ge_fw_name);
> +		mgp->fw_name = myri10ge_fw_name;
> +	} else if (old_fw == myri10ge_fw_aligned)
>  		mgp->fw_name = myri10ge_fw_rss_aligned;
>  	else
>  		mgp->fw_name = myri10ge_fw_rss_unaligned;
> 
> 
> --

applied


