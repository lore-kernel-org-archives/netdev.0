From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/4] bonding: Fix work initing and cancelling
Date: Tue, 15 Jan 2008 11:56:01 +0100
Message-ID: <20080115105601.GC1696@ff.dom.local>
References: <20080115063649.961619000@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:20125 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbYAOKtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 05:49:40 -0500
Received: by ug-out-1314.google.com with SMTP id z38so62290ugc.16
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 02:49:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080115063649.961619000@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-01-2008 07:36, Makito SHIOKAWA wrote:
...
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -643,10 +643,8 @@ static ssize_t bonding_store_arp_interva
>  		       "%s Disabling MII monitoring.\n",
>  		       bond->dev->name, bond->dev->name);
>  		bond->params.miimon = 0;
> -		if (delayed_work_pending(&bond->mii_work)) {
> -			cancel_delayed_work(&bond->mii_work);
> -			flush_workqueue(bond->wq);
> -		}
> +		cancel_delayed_work(&bond->mii_work);
> +		flush_workqueue(bond->wq);

I wonder why don't you use cancel_delayed_work_sync() here (and in a
few other places), like in bond_work_cancel_all() from patch 2/4?

Regards,
Jarek P.
