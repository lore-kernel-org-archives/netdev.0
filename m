From: David Miller <davem@davemloft.net>
Subject: Re: 5717 support commit is buggy
Date: Fri, 11 Sep 2009 15:41:25 -0700 (PDT)
Message-ID: <20090911.154125.182458823.davem@davemloft.net>
References: <20090911.151554.181296228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com, netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39921
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757128AbZIKWlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 18:41:09 -0400
In-Reply-To: <20090911.151554.181296228.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 11 Sep 2009 15:15:54 -0700 (PDT)

> I'm about to do some tests, but I suspect it's this change:
> 
> @@ -111,7 +111,8 @@
>   * replace things like '% foo' with '& (foo - 1)'.
>   */
>  #define TG3_RX_RCB_RING_SIZE(tp)	\
> -	((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ?  512 : 1024)
> +	(((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) && \
> +	  !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) ? 512 : 1024)
>  
>  #define TG3_TX_RING_SIZE		512
>  #define TG3_DEF_TX_RING_PENDING		(TG3_TX_RING_SIZE - 1)
> 
> and thus an incorrect RCB ring size is being used which eventually
> locks up the card.

Confirmed, reverting that part of the change makes my card
work again.

Broadcom folks, that is the correct test?  This needs to be fixed
urgently.
