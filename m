From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add checks if dev->netdev_ops is NULL in
 register_netdevice()
Date: Mon, 08 Apr 2013 08:16:34 -0700
Message-ID: <1365434194.3887.13.camel@edumazet-glaptop>
References: <51629159.9040000@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>,
	Xinwei Hu <huxinwei@huawei.com>
To: dingtianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:58439 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761819Ab3DHPQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 11:16:38 -0400
Received: by mail-ob0-f169.google.com with SMTP id wp18so5249444obc.14
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 08:16:38 -0700 (PDT)
In-Reply-To: <51629159.9040000@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 17:43 +0800, dingtianhong wrote:
> In some cases netdev->netdev_ops could be NULL in the register_netdevice(),
> thus a NULL point deference happens and lead to oops:

>  	/* Init, if this function is available */
> -	if (dev->netdev_ops->ndo_init) {
> +	if (dev->netdev_ops && dev->netdev_ops->ndo_init) {
>  		ret = dev->netdev_ops->ndo_init(dev);
>  		if (ret) {
>  			if (ret > 0)
> -- 1.8.0
> 

Seriously ?

This patch is not needed, and not complete anyway.

Fix the driver instead, we don't want this to happen.
