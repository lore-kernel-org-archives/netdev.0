From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] netconsole: avoid deadlock on printk from driver
 code
Date: Thu, 14 Aug 2008 15:15:02 -0700 (PDT)
Message-ID: <20080814.151502.251134900.davem@davemloft.net>
References: <20080813.033749.165504341.davem@davemloft.net>
	<84144f020808140628m31d6d099t1fecdb1701c0bbdc@mail.gmail.com>
	<Pine.LNX.4.64.0808141643200.3164@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@gmail.com, vegardno@ifi.uio.no,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, adobriyan@gmail.com
To: penberg@cs.helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45954
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751714AbYHNWPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 18:15:00 -0400
In-Reply-To: <Pine.LNX.4.64.0808141643200.3164@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka J Enberg <penberg@cs.helsinki.fi>
Date: Thu, 14 Aug 2008 16:44:32 +0300 (EEST)

> @@ -598,6 +598,7 @@
>  
>  	spinlock_t		lock;
>  	spinlock_t		rx_lock;
> +	spinlock_t		tx_lock;
>  
>  	chip_t			chipset;
>  	u32			rx_config;

Why create a special purpose lock when the generic networking
already is taking a lock for you to proect the TX path?

Furthermore, as I just described in another reply, netpoll
already knows that it might need to trylock() attempt on this
lock in order to avoid the very deadlocks this thread is
about.
