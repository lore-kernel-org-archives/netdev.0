From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] fix stack overflow in pktgen_if_write()
Date: Thu, 28 Oct 2010 00:40:57 +0200
Message-ID: <20101027224057.GP6062@bicker>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com> <20101027221234.GN6062@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	netdev@vger.kernel.org
To: nelhage@ksplice.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42305 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628Ab0J0WlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 18:41:10 -0400
Received: by wwe15 with SMTP id 15so1356555wwe.1
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 15:41:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101027221234.GN6062@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 12:12:35AM +0200, Dan Carpenter wrote:
> -		char tb[count + 1];
> -		if (copy_from_user(tb, user_buffer, count))
> -			return -EFAULT;
> -		tb[count] = 0;
> +		char *tb;
> +
> +		tb = strndup_user(user_buffer, count + 1);

Crap...  This should be memdup_user().

Sorry about that.  I'll send v2.

regards,
dan carpenter

> +		if (IS_ERR(tb))
> +			return PTR_ERR(tb);
>  		printk(KERN_DEBUG "pktgen: %s,%lu  buffer -:%s:-\n", name,
>  		       (unsigned long)count, tb);
> +		kfree(tb);
>  	}
>  
>  	if (!strcmp(name, "min_pkt_size")) {
