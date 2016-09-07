From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Minimum MTU Mess
Date: Wed, 7 Sep 2016 13:35:35 -0700
Message-ID: <20160907133535.2cfac7bc@xeon-e3>
References: <20160902170742.GA17677@redhat.com>
        <20160906.165529.496766310703537877.davem@davemloft.net>
        <20160907195356.GX33916@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36827 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753528AbcIGUf1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 16:35:27 -0400
Received: by mail-pf0-f175.google.com with SMTP id 128so9984387pfb.3
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 13:35:26 -0700 (PDT)
In-Reply-To: <20160907195356.GX33916@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Sep 2016 15:53:56 -0400
Jarod Wilson <jarod@redhat.com> wrote:

> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6466,9 +6466,17 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
>  	if (new_mtu == dev->mtu)
>  		return 0;
>  
> -	/*	MTU must be positive.	 */
> -	if (new_mtu < 0)
> +	if (new_mtu < dev->min_mtu) {
> +		netdev_err(dev, "Invalid MTU %d requested, hw min %d\n",
> +			   new_mtu, dev->min_mtu);
>  		return -EINVAL;
> +	}
> +
> +	if (new_mtu > dev->max_mtu) {
> +		netdev_err(dev, "Invalid MTU %d requested, hw max %d\n",
> +			   new_mtu, dev->min_mtu);
> +		return -EINVAL;
> +	}
>  

Maybe don't log something that can be triggered from a user program.
Or at least rate limit it.
