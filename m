From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] sched: replace bare printks
Date: Mon, 01 Sep 2014 18:16:10 -0700 (PDT)
Message-ID: <20140901.181610.1373857811532255466.davem@davemloft.net>
References: <20140829070918.508987897@networkplumber.org>
	<20140829071035.547171617@networkplumber.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45901 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbaIBBQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:16:11 -0400
In-Reply-To: <20140829071035.547171617@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 29 Aug 2014 00:09:23 -0700

> @@ -140,7 +140,7 @@ static int tcf_mirred(struct sk_buff *sk
>  
>  	dev = m->tcfm_dev;
>  	if (!dev) {
> -		printk_once(KERN_NOTICE "tc mirred: target device is gone\n");
> +		netdev_notice(dev, "tc mirred: target device is gone\n");
>  		goto out;

As pointed out by others, doing netdev_*() in a path where we know
'dev' is NULL doesn't make much sense.

Please respin this series with this adjusted.

Thanks.
