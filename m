From: David Miller <davem@davemloft.net>
Subject: Re: null pointer at cls_api.c
Date: Thu, 05 Aug 2010 13:07:55 -0700 (PDT)
Message-ID: <20100805.130755.57491167.davem@davemloft.net>
References: <282881281036255@web101.yandex.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: franchoze@yandex.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44355
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754230Ab0HEUHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 16:07:36 -0400
In-Reply-To: <282881281036255@web101.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Franchoze Eric <franchoze@yandex.ru>
Date: Thu, 05 Aug 2010 23:24:15 +0400

> @@ -255,6 +255,11 @@ replay:
>  			kfree(tp);
>  			goto errout;
>  		}
> +
> +		if (!tp || !tp->ops) {
> +			err = -ENOENT;
> +			goto errout;
> +		}
>  		tp->ops = tp_ops;
>  		tp->protocol = protocol;
>  		tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(*back));
> 

This patch makes no sense.

We check for "tp"  being non-NULL in the code block about the if() block you're
adding these checks to.

And tp->ops of course might be NULL here, and that's perfectly fine,
as we're about to assign "tp_ops" to it.

Looking at your backtrace I think perhaps your crash is elsewhere.
