From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Thu, 01 Apr 2010 18:43:45 -0700 (PDT)
Message-ID: <20100401.184345.85529643.davem@davemloft.net>
References: <1268765284.2932.17.camel@edumazet-laptop>
	<20100325113038.GA3471@swordfish.minsk.epam.com>
	<1270037311.2103.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergey.senozhatsky@gmail.com, oleg@redhat.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44803
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759068Ab0DBBno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:43:44 -0400
In-Reply-To: <1270037311.2103.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 31 Mar 2010 14:08:31 +0200

> [PATCH net-next-2.6] r8169: Fix rtl8169_rx_interrupt()
> 
> In case a reset is performed, rtl8169_rx_interrupt() is called from
> process context instead of softirq context. Special care must be taken
> to call appropriate network core services (netif_rx() instead of
> netif_receive_skb()). VLAN handling also corrected.
> 
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Diagnosed-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6, but:

> +/*
> + * Warning : rtl8169_rx_interrupt() might be called :
> + * 1) from NAPI (softirq) context
> + *	(polling = 1 : we should call netif_receive_skb())
> + * 2) from process context (rtl8169_reset_task())
> + *	(polling = 0 : we must call netif_rx() instead)
> + */		
      ^^^^^^^^

Trailing whitespace I had to delete.
