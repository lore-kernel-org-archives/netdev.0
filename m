From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix multicast on VLAN interfaces
Date: Sat, 23 Feb 2008 20:00:18 -0800 (PST)
Message-ID: <20080223.200018.128938227.davem@davemloft.net>
References: <20080221220542.GA19693@linuxace.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: kernel@linuxace.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42346
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752699AbYBXD7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 22:59:37 -0500
In-Reply-To: <20080221220542.GA19693@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Oester <kernel@linuxace.com>
Date: Thu, 21 Feb 2008 14:05:42 -0800

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 908f07c..999af2e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2905,6 +2905,7 @@ int __dev_addr_add(struct dev_addr_list **list, int *count,
>  		return -ENOMEM;
>  	memcpy(da->da_addr, addr, alen);
>  	da->da_addrlen = alen;
> +	da->da_synced = 0;
>  	da->da_users = 1;
>  	da->da_gusers = glbl ? 1 : 0;
>  	da->next = *list;

"da" is kzalloc()'d, how can da->da_synced not be zero?
