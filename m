From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/4] bonding: Fix work rearming
Date: Tue, 15 Jan 2008 10:05:32 +0100
Message-ID: <20080115090532.GB1696@ff.dom.local>
References: <20080115063650.149555000@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:27696 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbYAOI7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 03:59:12 -0500
Received: by ug-out-1314.google.com with SMTP id z38so51337ugc.16
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 00:59:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080115063650.149555000@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-01-2008 07:36, Makito SHIOKAWA wrote:
> Change code not to rearm bond_mii_monitor() when value 0 is set for miimon.
> 
> Signed-off-by: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
> ---
>  drivers/net/bonding/bond_main.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2388,7 +2388,8 @@ void bond_mii_monitor(struct work_struct
>  
>  	delay = ((bond->params.miimon * HZ) / 1000) ? : 1;
>  	read_unlock(&bond->lock);
> -	queue_delayed_work(bond->wq, &bond->mii_work, delay);
> +	if (bond->params.miimon)
> +		queue_delayed_work(bond->wq, &bond->mii_work, delay);
>  }

Maybe I miss something, but is this bond_mii_monitor() function
supposed to be ever started if (!bond->params.miimon)? (IOW: isn't
it enough to control this where the parameter is changed only?)

Regards,
Jarek P.
