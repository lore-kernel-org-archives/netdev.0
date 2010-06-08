From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] netdev:bfin_mac: reclaim and free tx skb as soon as
 possible after transfer
Date: Mon, 07 Jun 2010 21:22:38 -0700 (PDT)
Message-ID: <20100607.212238.209978119.davem@davemloft.net>
References: <1275907104.9082.1.camel@eight.analog.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53875
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750959Ab0FHEW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 00:22:27 -0400
In-Reply-To: <1275907104.9082.1.camel@eight.analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sonic zhang <sonic.adi@gmail.com>
Date: Mon, 7 Jun 2010 18:38:24 +0800

>  
> +	if (timer_pending(&lp->tx_reclaim_timer))
> +		del_timer(&(lp->tx_reclaim_timer));
> +

Please remove the excess parenthesis around lp->tx_reclaim_timer being
passed to del_timer().

Also, you can unconditionally call del_timer().  If the timer isn't running
the call won't do anything.

But you have to do something to make sure you don't race with the code that
enables the timer, f.e. what keeps the timer from being scheduled right
after you make this del_timer() call?
