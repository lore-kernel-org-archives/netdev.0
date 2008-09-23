From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: network device name ifalias support
Date: Mon, 22 Sep 2008 19:44:23 -0700 (PDT)
Message-ID: <20080922.194423.116365505.davem@davemloft.net>
References: <20080922174346.2ad15d26@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56355
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754116AbYIWCof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:44:35 -0400
In-Reply-To: <20080922174346.2ad15d26@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 22 Sep 2008 17:43:46 -0700

> +	dev->ifalias = krealloc(dev->ifalias, len+1, GFP_KERNEL);
> +	if (!dev->ifalias)
> +		return -ENOMEM;
> +
> +	strlcpy(dev->ifalias, alias, len+1);
> +	return len;

It might be cleaner to use kstrdup() and free the old pointer, if
any, here.

	char *new = kstrdup(alias, GFP_KERNEL);
	if (!new)
		return -ENOMEM;
	kfree(dev->ifalias);
	dev->ifalias = new;
	return len;

That way all of this "len+1" stuff goes away.
